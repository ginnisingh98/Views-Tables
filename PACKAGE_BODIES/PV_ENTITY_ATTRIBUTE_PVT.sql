--------------------------------------------------------
--  DDL for Package Body PV_ENTITY_ATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTITY_ATTRIBUTE_PVT" AS
 /* $Header: pvxveatb.pls 120.4 2007/08/14 08:50:54 rnori ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Entity_Attribute_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME  CONSTANT  VARCHAR2(30)  := 'PV_Entity_Attribute_PVT';
G_FILE_NAME CONSTANT  VARCHAR2(12)  := 'pvxveatb.pls';

G_USER_ID         NUMBER := Fnd_Global.USER_ID;
G_LOGIN_ID        NUMBER := Fnd_Global.CONC_LOGIN_ID;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Entity_Attr(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_entity_attr_rec         IN   entity_attr_rec_type  := g_miss_entity_attr_rec
    ,x_entity_attr_id             OUT NOCOPY  NUMBER
     )


 IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Entity_Attr';
   l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_api_version_number        CONSTANT NUMBER       := 1.0;
   l_return_status_full                 VARCHAR2(1);
   l_object_version_number              NUMBER       := 1;
   l_org_id                             NUMBER       := Fnd_Api.G_MISS_NUM;
   l_ENTITY_ATTR_ID                     NUMBER;
   l_dummy                              NUMBER;
   l_entity_attr_rec        entity_attr_rec_type  := p_entity_attr_rec;
   l_attribute_type			VARCHAR2(30);
   l_display_style			VARCHAR2(30);
   l_meaning				VARCHAR2(80);

   l_lov_string				varchar2(2000);


   CURSOR c_id IS
      SELECT PV_ENTITY_ATTRS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_ENTITY_ATTRS
      WHERE ENTITY_ATTR_ID = l_id;

   CURSOR c_get_attr_details(cv_attribute_id NUMBER) IS
	SELECT attribute_type, display_style
	from pv_attributes_vl
	where attribute_id=cv_attribute_id
	;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Entity_Attr_PVT;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;

      -- Debug Message
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || ' start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


-- getting attribute type  and find if it is of FUNCTION type, If it is FUNCTION tytpe
	   -- validate sqltext before updating

	   for x in c_get_attr_details (cv_attribute_id =>p_entity_attr_rec.attribute_id)
	   loop

			l_attribute_type := x.attribute_type ;
			l_display_style  := x.display_style;
           end loop;



-- User can not enable Opportunity entity for attri9butes other than type= DropDown, Style = Multi-Select, Single-Select, Radio-Button, Check-Box

/*	    if(p_entity_attr_rec.entity='LEAD'
	      and not (l_attribute_type = 'DROPDOWN'
	      and l_display_style in ('CHECK','MULTI','SINGLE','RADIO'))
	      ) then

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_ENTY_ATTR_ERROR');
			  FOR x IN (select meaning from pv_lookups
			            where lookup_type = 'PV_ATTRIBUTE_ENTITY_TYPE'
				    and lookup_code = p_entity_attr_rec.entity
				   ) LOOP
				l_meaning := x.meaning;
			  END LOOP;
			  Fnd_Message.set_token('ENTITY',l_meaning);

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
     */

	   if(l_attribute_type= 'FUNCTION') then

			validate_sql_text(
						 p_api_version_number         => p_api_version_number
						,p_init_msg_list              => p_init_msg_list
						,p_commit                     => p_commit
						,p_validation_level           => p_validation_level

						,x_return_status              => x_return_status
						,x_msg_count                  => x_msg_count
						,x_msg_data                   => x_msg_data

						,p_sql_text			   => p_entity_attr_rec.sql_text
						,p_entity			   => p_entity_attr_rec.entity


			);




			IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
				RAISE Fnd_Api.G_EXC_ERROR;
			END IF;
	   end if;



   -- Local variable initialization

   IF p_entity_attr_rec.ENTITY_ATTR_ID IS NULL OR
      p_entity_attr_rec.ENTITY_ATTR_ID = Fnd_Api.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_ENTITY_ATTR_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_ENTITY_ATTR_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
    ELSE
       l_ENTITY_ATTR_ID := p_entity_attr_rec.ENTITY_ATTR_ID;
   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF Fnd_Global.User_Id IS NULL
      THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= Fnd_Api.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Validate_Entity_Attr');
           END IF;
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before Validate_Entity_Attr' );

           -- Populate the default required items
           l_entity_attr_rec.entity_attr_id        := l_entity_attr_id;
           l_entity_attr_rec.last_update_date      := SYSDATE;
           l_entity_attr_rec.last_updated_by       := G_USER_ID;
           l_entity_attr_rec.creation_date         := SYSDATE;
           l_entity_attr_rec.created_by            := G_USER_ID;
           l_entity_attr_rec.last_update_login     := G_LOGIN_ID;
           l_entity_attr_rec.object_version_number := l_object_version_number;

          -- Invoke validation procedures
          Validate_Entity_Attr(
             p_api_version_number  => 1.0
            ,p_init_msg_list       => Fnd_Api.G_FALSE
            ,p_validation_level    => p_validation_level
            ,p_validation_mode     => Jtf_Plsql_Api.g_create
            ,p_entity_attr_rec     => l_entity_attr_rec
            ,x_return_status       => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
            );

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Validate_Entity_Attr' );

      END IF;

      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Validate' );

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message( 'Private API: Calling create table handler');
      END IF;

      --display flag should be Y for LEAd entity for the following types
      -- to suport OTS attrs.

      if(p_entity_attr_rec.entity='LEAD') then

	 if( l_attribute_type = 'DROPDOWN'
         and l_display_style in ('CHECK','MULTI','SINGLE','RADIO')
	 ) then

		l_entity_attr_rec.display_flag := 'Y';

	else
		l_entity_attr_rec.display_flag := 'N';
	end if;
      end if;


    l_lov_string := l_entity_attr_rec.lov_string;




      -- Invoke table handler(PV_ENTITY_ATTRS_PKG.Insert_Row)
      Pv_Entity_Attrs_Pkg.Insert_Row(
           px_entity_attr_id         => l_entity_attr_rec.entity_attr_id
          ,px_object_version_number  => l_object_version_number
	  ,p_batch_sql_text          => l_entity_attr_rec.batch_sql_text
	  ,p_refresh_frequency       => l_entity_attr_rec.refresh_frequency
	  ,p_refresh_frequency_uom   => l_entity_attr_rec.refresh_frequency_uom
	  ,p_last_refresh_date       => l_entity_attr_rec.last_refresh_date
	  ,p_display_external_value_flag   => l_entity_attr_rec.display_external_value_flag
          ,p_lov_string              =>  l_lov_string  --replace(l_lov_string,':1','?')
          ,p_enabled_flag            => l_entity_attr_rec.enabled_flag
	  ,p_display_flag            => l_entity_attr_rec.display_flag
          ,p_locator_flag            => l_entity_attr_rec.locator_flag
          ,p_entity_type	     => l_entity_attr_rec.entity_type
          ,p_require_validation_flag => l_entity_attr_rec.require_validation_flag
 	  ,p_external_update_text    => l_entity_attr_rec.external_update_text
          ,p_attribute_id            => l_entity_attr_rec.attribute_id
          ,p_entity                  => l_entity_attr_rec.entity
          ,p_sql_text                => l_entity_attr_rec.sql_text
          ,p_attr_data_type          => l_entity_attr_rec.attr_data_type
          ,p_creation_date           => l_entity_attr_rec.creation_date
          ,p_created_by              => l_entity_attr_rec.created_by
	  ,p_last_updated_by         => l_entity_attr_rec.last_updated_by
          ,p_last_update_date        => l_entity_attr_rec.last_update_date
          ,p_last_update_login       => l_entity_attr_rec.last_update_login);



--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After' );

          x_entity_attr_id := l_entity_attr_id;

      IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
--
-- End of API body
--
      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
	  END IF;
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
/*
   WHEN PV_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PV_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
*/
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO Create_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO Create_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Create_Entity_Attr;

PROCEDURE Update_Entity_Attr(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_entity_attr_rec         IN   entity_attr_rec_type
    ,x_object_version_number      OUT NOCOPY  NUMBER
    )
 IS

CURSOR c_get_entity_attribute(cv_entity_attr_id NUMBER) IS
    SELECT *
    FROM  PV_ENTITY_ATTRS
    WHERE ENTITY_ATTR_ID = cv_entity_attr_id;

CURSOR c_get_attr_details(cv_attribute_id NUMBER) IS
	SELECT attribute_type,display_style
	from pv_attributes_vl
	where attribute_id=cv_attribute_id
	;


l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Entity_Attr';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_ENTITY_ATTR_ID            NUMBER;
l_ref_entity_attr_rec    c_get_Entity_Attribute%ROWTYPE ;
l_tar_entity_attr_rec    Pv_Entity_Attribute_Pvt.entity_attr_rec_type := p_entity_attr_rec;
l_rowid                     ROWID;
l_attribute_type			VARCHAR2(30);
l_display_style			VARCHAR2(30) ;
l_lov_result			VARCHAR2(32000) ;
l_lov_string	varchar2(2000);

 BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Update_Entity_Attr_PVT;
      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: - Open Cursor to Select');
      END IF;
      OPEN c_get_Entity_Attribute( l_tar_entity_attr_rec.entity_attr_id);

      FETCH c_get_Entity_Attribute INTO l_ref_entity_attr_rec  ;

       IF ( c_get_Entity_Attribute%NOTFOUND) THEN
           Fnd_Message.set_name('PV', 'PV_API_MISSING_ENTITY');
           Fnd_Message.set_token('MODE','Update');
           Fnd_Message.set_token('ENTITY','Entity_Attribute');
           Fnd_Message.set_token('ID',TO_CHAR(l_tar_entity_attr_rec.entity_attr_id));
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       -- Debug Message
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		 PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Close Cursor');
		 END IF;

       CLOSE     c_get_Entity_Attribute;


	   -- getting attribute type  and find if it is of FUNCTION type, If it is FUNCTION tytpe
	   -- validate sqltext before updating

	   for x in c_get_attr_details (cv_attribute_id =>l_ref_entity_attr_rec.attribute_id)
	   loop

			l_attribute_type := x.attribute_type ;
			l_display_style  := x.display_style;
       end loop;


	   if(l_attribute_type= 'FUNCTION' ) then
		-- if(p_entity_attr_rec.sql_text <> null and p_entity_attr_rec.sql_text <> '') then
		if( p_entity_attr_rec.sql_text IS NOT NULL ) then
			validate_sql_text(
						 p_api_version_number         => p_api_version_number
						,p_init_msg_list              => p_init_msg_list
						,p_commit                     => p_commit
						,p_validation_level           => p_validation_level

						,x_return_status              => x_return_status
						,x_msg_count                  => x_msg_count
						,x_msg_data                   => x_msg_data

						,p_sql_text			   => p_entity_attr_rec.sql_text
						,p_entity			   => p_entity_attr_rec.entity


			);
		end if;
		IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
			RAISE Fnd_Api.G_EXC_ERROR;
		END IF;


		if(l_display_style='LOV') then
			if(p_entity_attr_rec.lov_string <> null and p_entity_attr_rec.lov_string <> '') then

				validate_Lov_String(
						 p_api_version_number         => p_api_version_number
						,p_init_msg_list              => p_init_msg_list
						,p_commit                     => p_commit
						,p_validation_level           => p_validation_level

						,x_return_status              => x_return_status
						,x_msg_count                  => x_msg_count
						,x_msg_data                   => x_msg_data
						,p_lov_string		      => p_entity_attr_rec.lov_string
						,p_entity		      => p_entity_attr_rec.entity
						,p_attribute_id		      => p_entity_attr_rec.attribute_id
						,x_lov_result		      => l_lov_result
			);
		end if;
		IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
			RAISE Fnd_Api.G_EXC_ERROR;
		END IF;
		end if;
	    end if;
      IF (l_tar_entity_attr_rec.object_version_number IS NULL OR
          l_tar_entity_attr_rec.object_version_number = Fnd_Api.G_MISS_NUM ) THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_VERSION_MISSING');
			  Fnd_Message.set_token('COLUMN','Last_Update_Date');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      -- Check Whether record has been changed by someone else
--DBMS_OUTPUT.PUT_LINE('l_tar_entity_attr_rec.object_version_number = '||TO_CHAR(l_tar_entity_attr_rec.object_version_number));
--DBMS_OUTPUT.PUT_LINE('l_ref_entity_attr_rec.object_version_number = '||TO_CHAR(l_ref_entity_attr_rec.object_version_number));
      IF (l_tar_entity_attr_rec.object_version_number <> l_ref_entity_attr_rec.object_version_number) THEN
	   Fnd_Message.set_name('PV', 'PV_API_RECORD_CHANGED');
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   Fnd_Message.set_token('VALUE','Entity_Attribute');
			   Fnd_Msg_Pub.ADD;
		   END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= Fnd_Api.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		  Pvx_Utility_Pvt.debug_message('Private API: Validate_Entity_Attr');
		  END IF;
          -- Invoke validation procedures
          Validate_Entity_Attr(
             p_api_version_number  => 1.0
            ,p_init_msg_list       => Fnd_Api.G_FALSE
            ,p_validation_level    => p_validation_level
            ,p_validation_mode     => Jtf_Plsql_Api.g_update
            ,p_entity_attr_rec  =>  p_entity_attr_rec
            ,x_return_status       => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data);
      END IF;
      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
      Pvx_Utility_Pvt.debug_message('Private API: '||l_full_name||' - Calling update table handler');
      END IF;


      l_lov_string := p_entity_attr_rec.lov_string;

      -- Invoke table handler(PV_ENTITY_ATTRS_PKG.Update_Row)
      Pv_Entity_Attrs_Pkg.Update_Row(
           p_entity_attr_id         => p_entity_attr_rec.entity_attr_id
          ,p_last_update_date       => SYSDATE
          ,p_last_updated_by        => G_USER_ID
          ,p_last_update_login      => G_LOGIN_ID
          ,p_object_version_number  => p_entity_attr_rec.object_version_number
          ,p_attribute_id           => p_entity_attr_rec.attribute_id
          ,p_entity                 => p_entity_attr_rec.entity
	  ,p_entity_type            => p_entity_attr_rec.entity_type
          ,p_sql_text               => p_entity_attr_rec.sql_text
          ,p_attr_data_type         => p_entity_attr_rec.attr_data_type
          ,p_lov_string             => l_lov_string --replace(l_lov_string,':1','?') --replacing :1 with ? as we are storing java bindings
          ,p_enabled_flag           => p_entity_attr_rec.enabled_flag
          ,p_display_flag           => p_entity_attr_rec.display_flag
          ,p_locator_flag           => p_entity_attr_rec.locator_flag
	  ,p_require_validation_flag=> p_entity_attr_rec.require_validation_flag
	  ,p_external_update_text          => p_entity_attr_rec.external_update_text
	  ,p_refresh_frequency          => p_entity_attr_rec.refresh_frequency
	  ,p_refresh_frequency_uom          => p_entity_attr_rec.refresh_frequency_uom
	  ,p_batch_sql_text          => p_entity_attr_rec.batch_sql_text
	  ,p_last_refresh_date          => p_entity_attr_rec.last_refresh_date
	  ,p_display_external_value_flag   => p_entity_attr_rec.display_external_value_flag


          );

      x_object_version_number := p_entity_attr_rec.object_version_number + 1;
      --
      -- End of API body.
      --
      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
	  END IF;
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
/*
   WHEN PV_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PV_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
*/
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO Update_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO Update_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Update_Entity_Attr;

PROCEDURE Validate_sql_text(
    p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

	,p_sql_text					  IN   VARCHAR2
    ,p_entity					  IN   VARCHAR2

    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_sql_text';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_error_code				VARCHAR2(30);
l_error_message				VARCHAR2(1000);
l_parse_error1				VARCHAR2(1) := 'N';
l_parse_error2				VARCHAR2(1) := 'N';
v_cursor					NUMBER;

l_left_bracket_pos					NUMBER;
l_right_bracket_pos				NUMBER;
l_exec_sql_text					VARCHAR2(2000);
l_package_name				VARCHAR2(1000);
l_entity_meaning                        VARCHAR2(80);
CURSOR c_get_lookup_meaning(cv_lookup_code VARCHAR2) IS
	select meaning from pv_lookups
	where lookup_type = 'PV_ATTRIBUTE_ENTITY_TYPE'
	and lookup_code= cv_lookup_code
	;


 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Validate_sql_text;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'Start');
      END IF;

-- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


      for x in c_get_lookup_meaning (cv_lookup_code =>p_entity)
	   loop

			l_entity_meaning := x.meaning ;
      end loop;



	  v_cursor := DBMS_SQL.open_cursor;
      --since i am making this more generic, I first check for normal sql statements and for procedures
	  --check for nmormal sql text

	  /*begin
		DBMS_SQL.parse(v_cursor, ''||p_sql_text ,DBMS_SQL.NATIVE);

	  exception
		when others then
			l_error_code := ''||SQLCODE;
			l_error_message := ''|| SQLERRM;
			l_parse_error1 := 'Y';
	  end;
	  */
	  --for procedures



		l_left_bracket_pos := instr(p_sql_text,'(');

		l_right_bracket_pos := instr(p_sql_text,')');


		if((l_left_bracket_pos = 0 or l_right_bracket_pos = 0) and p_sql_text is not null ) then

			 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			  --IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  THEN

				  FND_MESSAGE.Set_Name('PV', 'PV_DERIVED_SQLTEXT_SYNTX_ERROR');
				  FND_MESSAGE.Set_Token('ENTITY',l_entity_meaning);
				  --FND_MESSAGE.Set_Token('ERROR_CODE',l_error_code);
				  --FND_MESSAGE.Set_Token('ERROR_MESSAGE',l_error_message );
				  FND_MSG_PUB.Add;
			  END IF;

			  RAISE FND_API.G_EXC_ERROR;
		end if;


		l_package_name := substr(p_sql_text,0,l_left_bracket_pos-1);
		l_package_name := ltrim(l_package_name);
		l_package_name := rtrim(l_package_name);



		--this check is for testing for number of parameters that are passing to procedure are 2 .
		-- so for that, seeing diference betwwen the legnths of original sql_text and the test after replacing : with ''

		if( p_sql_text is not null  and
			((length(p_sql_text)- length(replace(p_sql_text,':','')) <>2)  or
		    (length(p_sql_text)- length(replace(p_sql_text,',','')) <>1)
			)
		  ) then
			-- no of parameters are more
			 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			  --IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  THEN

				  FND_MESSAGE.Set_Name('PV', 'PV_DERIVED_SQLTEXT_SYNTX_ERROR');
				  FND_MESSAGE.Set_Token('ENTITY',l_entity_meaning);
				  --FND_MESSAGE.Set_Token('ERROR_CODE',l_error_code);
				  --FND_MESSAGE.Set_Token('ERROR_MESSAGE',l_error_message );
				  FND_MSG_PUB.Add;
			  END IF;

			  RAISE FND_API.G_EXC_ERROR;
		end if;


	  --parsing the procedure
	  begin
		--forming sql block to parse the procedure and see if procedure is valid one.
		if(p_sql_text is not null ) then
			l_exec_sql_text := 'declare l_out jtf_varchar2_table_4000; begin ' || l_package_name || '(1,l_out);end;';
		  --l_exec_sql_text := 'declare l_out varchar2(500); begin ' || l_package_name || '(1,l_out);end;';
			DBMS_SQL.parse(v_cursor, l_exec_sql_text ,DBMS_SQL.NATIVE);
		end if;

	  exception
		when others then
			l_error_code := ''||SQLCODE;
			l_error_message := ''|| SQLERRM;
			l_parse_error2 := 'Y';

			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		  --IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	      THEN

			  --FND_MESSAGE.Set_Name('PV', 'PV_DERIVED_SQLTEXT_PARSE_ERROR');
			  FND_MESSAGE.Set_Name('PV', 'PV_DERIVED_SQLTEXT_SYNTX_ERROR');

			  FND_MESSAGE.Set_Token('ENTITY',l_entity_meaning);
			 --FND_MESSAGE.Set_Token('ERROR_CODE',l_error_code);
			 --FND_MESSAGE.Set_Token('ERROR_MESSAGE',l_error_message );
              FND_MSG_PUB.Add;
          END IF;

          RAISE FND_API.G_EXC_ERROR;

	  end;


     if(l_parse_error2 = 'Y' and p_sql_text is not null ) then
		  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		  --IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	      THEN

			  FND_MESSAGE.Set_Name('PV', 'PV_DERIVED_SQLTEXT_SYNTX_ERROR');
			  --FND_MESSAGE.Set_Name('PV', 'PV_DERIVED_SQLTEXT_PARSE_ERROR');
			  FND_MESSAGE.Set_Token('ENTITY',l_entity_meaning);
			  --FND_MESSAGE.Set_Token('ERROR_CODE',l_error_code);
			  --FND_MESSAGE.Set_Token('ERROR_MESSAGE',l_error_message );
              FND_MSG_PUB.Add;
          END IF;

          RAISE FND_API.G_EXC_ERROR;
	 end if;
      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      -- Debug Message
      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count
         ,p_data           =>   x_msg_data
      );
EXCEPTION
/*
   WHEN PV_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PV_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
*/
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO Validate_sql_text;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_sql_text;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_sql_text;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );
END Validate_sql_text;

PROCEDURE Validate_Lov_String(
    p_api_version_number          IN	NUMBER
    ,p_init_msg_list              IN	VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN	VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN	NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,x_return_status              OUT	NOCOPY	VARCHAR2
    ,x_msg_count                  OUT	NOCOPY  NUMBER
    ,x_msg_data                   OUT	NOCOPY  VARCHAR2

    ,p_lov_string		  IN	VARCHAR2
    ,p_entity			  IN	VARCHAR2
    ,p_attribute_id		  IN	NUMBER
    ,x_lov_result		  OUT NOCOPY  VARCHAR2
    )

 IS

l_api_name			CONSTANT VARCHAR2(30) := 'Validate_Lov_String';
l_full_name			CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number		CONSTANT NUMBER       := 1.0;
l_error_code			VARCHAR2(30);
l_error_message			VARCHAR2(1000);
l_parse_error1			VARCHAR2(1) := 'N';
l_parse_error2			VARCHAR2(1) := 'N';
v_cursor			NUMBER;


l_exec_sql_text			VARCHAR2(30000);

l_lookup_code                   VARCHAR2(30) ;
l_lookup_meaning                VARCHAR2(80) ;
l_lookup_description            VARCHAR2(240);

l_lov_result			VARCHAR2(32000);

TYPE		c_lov_type	IS REF CURSOR;

lc_lov_cursor			c_lov_type;

l_lov_string			varchar2(2000);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Validate_lov_string;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    --replacing java bindings with pl/sql bindings.
     l_lov_string := replace(p_lov_string,'?',':1');



	  v_cursor := DBMS_SQL.open_cursor;
	  --for procedures


		--this check is for testing for number of parameters that are passing to procedure are 2 .
		-- so for that, seeing diference betwwen the legnths of original sql_text and the test after replacing : with ''

	  --parsing the procedure
	  begin
		--forming sql block to parse the procedure and see if procedure is valid one.
		/*if(p_lov_string is not null ) then
			l_exec_sql_text := 'declare lookup_code  VARCHAR2(30); lookup_meaning  VARCHAR2(80); lookup_description  VARCHAR2(240); begin ' ||
			'execute immediate ' ||''''|| l_lov_string || '''' ||
			' into lookup_code, lookup_meaning, lookup_description ' ||
			' using '|| p_attribute_id ||  ' ; end;'
			;
		  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API: ' || 'The query:--' || l_exec_sql_text);
			END IF;

			DBMS_SQL.parse(v_cursor, l_exec_sql_text ,DBMS_SQL.NATIVE);
*/

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API: ' || 'Before opening cursor' );
		END IF;

		OPEN lc_lov_cursor FOR l_lov_string USING p_attribute_id;
		LOOP


			FETCH lc_lov_cursor INTO l_lookup_code, l_lookup_meaning, l_lookup_description;
			EXIT WHEN lc_lov_cursor%NOTFOUND;
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API: ' || 'Before fetching1' );
			END IF;


			l_lov_result := l_lov_result ||  l_lookup_meaning || ', ';

			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API:' || l_lookup_meaning || ':' );
			END IF;


		END LOOP;

		CLOSE lc_lov_cursor;

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			Pvx_Utility_Pvt.debug_message('Private API: ' || 'closing cursor' );
		END IF;

		x_lov_result := substr(l_lov_result,1, length(l_lov_result)-2);



	  exception
		when others then
			l_error_code := ''||SQLCODE;
			l_error_message := ''|| SQLERRM;
			l_parse_error2 := 'Y';


			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API: ' || 'error Code:--' || l_error_code);
			END IF;

			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API: ' || 'error Message:--' || l_error_message);
			END IF;

			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		  --IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
	      THEN

			  --FND_MESSAGE.Set_Name('PV', 'PV_DERIVED_SQLTEXT_PARSE_ERROR');
			  FND_MESSAGE.Set_Name('PV', 'PV_DERIVED_LOV_SYNTX_ERROR');

			  --FND_MESSAGE.Set_Token('ENTITY',l_entity_meaning);
			 --FND_MESSAGE.Set_Token('ERROR_CODE',l_error_code);
			 --FND_MESSAGE.Set_Token('ERROR_MESSAGE',l_error_message );
              FND_MSG_PUB.Add;
          END IF;

          RAISE FND_API.G_EXC_ERROR;

	  end;

	 IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API: ' || 'Lov String:--' || l_lov_string);
			END IF;
     /*
     if(l_parse_error2 = 'Y' and l_lov_string is not null ) then
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		  --IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		THEN

			  FND_MESSAGE.Set_Name('PV', 'PV_DERIVED_LOV_SYNTX_ERROR');
			  --FND_MESSAGE.Set_Name('PV', 'PV_DERIVED_SQLTEXT_PARSE_ERROR');
			 -- FND_MESSAGE.Set_Token('ENTITY',l_entity_meaning);
			  --FND_MESSAGE.Set_Token('ERROR_CODE',l_error_code);
			  --FND_MESSAGE.Set_Token('ERROR_MESSAGE',l_error_message );
			FND_MSG_PUB.Add;
		END IF;

		RAISE FND_API.G_EXC_ERROR;
      else

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API: ' || 'Before opening cursor' );
		END IF;

		OPEN lc_lov_cursor FOR l_lov_string USING p_attribute_id;
		LOOP
			EXIT WHEN lc_lov_cursor%NOTFOUND;
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API: ' || 'Before fetching1' );
			END IF;

			FETCH lc_lov_cursor INTO l_lookup_code, l_lookup_meaning, l_lookup_description;

			l_lov_result := l_lov_result || ',' || l_lookup_meaning || ' ';
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API:' || l_lookup_meaning || ':' );
			END IF;

		END LOOP;

		CLOSE lc_lov_cursor;

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				Pvx_Utility_Pvt.debug_message('Private API: ' || 'closing cursor' );
		END IF;
		x_lov_result := substr(l_lov_result,1, length(l_lov_result)-1);

      end if;
      */


      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      -- Debug Message
      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count
         ,p_data           =>   x_msg_data
      );
EXCEPTION
/*
   WHEN PV_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PV_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
*/
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO Validate_lov_string;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_lov_string;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_lov_string;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );
END Validate_lov_string;


PROCEDURE Delete_Entity_Attr(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_entity_attr_id                   IN  NUMBER
    ,p_object_version_number      IN   NUMBER
    )
 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Entity_Attr';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_delete_flag	            VARCHAR2(1):='Y';
l_being_used_list	        VARCHAR2(30000);

l_attribute_name            VARCHAR2(60);
l_entity				    VARCHAR2(60);

cursor lc_entity_attribute_details (pc_entity_attr_id number) is
	select attr.name, enty.entity
	from   pv_attributes_vl attr, pv_entity_attrs enty
	where  enty.entity_attr_id=pc_entity_attr_id and
		   enty.attribute_id=attr.attribute_id
		   ;

cursor lc_attribute_programs (pc_entity_attr_id number) is
	select	prg.program_name
	from	pv_partner_program_vl prg, pv_ge_qsnr_elements_b qsnr
	where	qsnr.used_by_entity_id = prg.program_id and
			entity_attr_id = pc_entity_attr_id
			;
 cursor lc_check_attr_enty_vals (pc_entity_attr_id number) is
   select distinct val.entity
   from pv_enty_attr_values val, pv_entity_attrs enty
   where enty.entity_attr_id =pc_entity_attr_id and
		 enty.attribute_id = val.attribute_id and
		 enty.entity = val.entity
		 ;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Entity_Attr_PVT;
      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;
      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
	  END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      --
      -- Api body
      --

	  -- get attribute details
	  for x in lc_entity_attribute_details (pc_entity_attr_id =>p_entity_attr_id)
      loop
        l_attribute_name:= x.name;
		l_entity := x.entity;
      end loop;



	 --check if it is being reference by any entity values
	   for x in lc_check_attr_enty_vals (pc_entity_attr_id =>p_entity_attr_id)
      loop
        l_delete_flag := 'N' ;
		--l_being_used_list := l_being_used_list || ','|| x.program_name ;
      end loop;


      if(l_delete_flag = 'N') then

		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
              FND_MESSAGE.Set_Name('PV', 'PV_ENTITYATTR_REF_VALUE');
              FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',l_attribute_name );
			  FND_MESSAGE.Set_Token('ENTITY',l_attribute_name );
			  --FND_MESSAGE.Set_Token('PROGRAM_LIST',substr(l_being_used_list,2) );
              FND_MSG_PUB.Add;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

     end if;


	  --check if it is being reference by any program
	  for x in lc_attribute_programs (pc_entity_attr_id =>p_entity_attr_id)
      loop
        l_delete_flag := 'N' ;
		l_being_used_list := l_being_used_list || ','|| x.program_name ;
      end loop;


      if(l_delete_flag = 'N') then

		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
              FND_MESSAGE.Set_Name('PV', 'PV_ENTITYATTR_REF_PROGRAM');
              FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',l_attribute_name );
			  FND_MESSAGE.Set_Token('ENTITY',l_attribute_name );
			  FND_MESSAGE.Set_Token('PROGRAM_LIST',substr(l_being_used_list,2) );
              FND_MSG_PUB.Add;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

     end if;




      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message( 'Private API: Calling delete table handler');
	  END IF;
      -- Invoke table handler(PV_ENTITY_ATTRS_PKG.Delete_Row)
      Pv_Entity_Attrs_Pkg.Delete_Row(
          p_ENTITY_ATTR_ID  => p_ENTITY_ATTR_ID);
      --
      -- End of API body
      --
      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
	  END IF;
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
/*
   WHEN PV_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PV_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
*/
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO Delete_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Delete_Entity_Attr;

-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Entity_Attr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_entity_attr_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )
 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_Entity_Attr';
l_api_version_number        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_ENTITY_ATTR_ID                  NUMBER;
CURSOR c_Entity_Attribute IS
   SELECT ENTITY_ATTR_ID
   FROM PV_ENTITY_ATTRS
   WHERE ENTITY_ATTR_ID = p_ENTITY_ATTR_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;
BEGIN
      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
	  END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;
      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

------------------------ lock -------------------------
  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
  Pvx_Utility_Pvt.debug_message(l_full_name||': start');
  END IF;
  OPEN c_Entity_Attribute;
  FETCH c_Entity_Attribute INTO l_ENTITY_ATTR_ID;
  IF (c_Entity_Attribute%NOTFOUND) THEN
    CLOSE c_Entity_Attribute;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
       Fnd_Message.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       Fnd_Msg_Pub.ADD;
    END IF;
    RAISE Fnd_Api.g_exc_error;
  END IF;
  CLOSE c_Entity_Attribute;
 -------------------- finish --------------------------
  Fnd_Msg_Pub.count_and_get(
    p_encoded => Fnd_Api.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
  Pvx_Utility_Pvt.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION
/*
   WHEN PV_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PV_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
*/
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO Lock_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Lock_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO Lock_Entity_Attr_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;

     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Lock_Entity_Attr;

PROCEDURE check_uk_items(
    p_entity_attr_rec         IN  entity_attr_rec_type,
    p_validation_mode            IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);
BEGIN
      x_return_status := Fnd_Api.g_ret_sts_success;
      IF p_validation_mode = Jtf_Plsql_Api.g_create THEN
         l_valid_flag := Pvx_Utility_Pvt.check_uniqueness(
         'PV_ENTITY_ATTRS',
         'ENTITY_ATTR_ID = ''' || p_entity_attr_rec.ENTITY_ATTR_ID ||''''
         );
      ELSE
         l_valid_flag := Pvx_Utility_Pvt.check_uniqueness(
         'PV_ENTITY_ATTRS',
         'ENTITY_ATTR_ID = ''' || p_entity_attr_rec.ENTITY_ATTR_ID ||
         ''' AND ENTITY_ATTR_ID <> ' || p_entity_attr_rec.ENTITY_ATTR_ID
         );
      END IF;
      IF l_valid_flag = Fnd_Api.g_false THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
			  Fnd_Message.set_token('ID',TO_CHAR(p_entity_attr_rec.entity_attr_ID) );
			  Fnd_Message.set_token('ENTITY','Entity_Attribute');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
END check_uk_items;

PROCEDURE check_req_items(
     p_entity_attr_rec   IN  entity_attr_rec_type
    ,p_validation_mode      IN  VARCHAR2                := Jtf_Plsql_Api.g_create
    ,x_return_status	    OUT NOCOPY VARCHAR2
    )
IS
BEGIN

--DBMS_OUTPUT.PUT_LINE('p_validation_mode = '||p_validation_mode);

   x_return_status := Fnd_Api.g_ret_sts_success;

   IF p_validation_mode = Jtf_Plsql_Api.g_create THEN

--DBMS_OUTPUT.PUT_LINE('Before calling entity_attribute');

--                    TO_CHAR(p_entity_attr_rec.entity_attr_id));
      IF p_entity_attr_rec.entity_attr_id = Fnd_Api.g_miss_num
         OR p_entity_attr_rec.entity_attr_id IS NULL THEN
		  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','entity_attr_id');
			  Fnd_Msg_Pub.ADD;
		   END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.last_update_date = Fnd_Api.g_miss_date OR p_entity_attr_rec.last_update_date IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','last_update_date');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.last_updated_by = Fnd_Api.g_miss_num OR p_entity_attr_rec.last_updated_by IS NULL THEN
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','last_updated_by');
			  Fnd_Msg_Pub.ADD;
			 END IF;
		  x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.creation_date = Fnd_Api.g_miss_date OR p_entity_attr_rec.creation_date IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','creation_date');
			  Fnd_Msg_Pub.ADD;
		   END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.created_by = Fnd_Api.g_miss_num OR p_entity_attr_rec.created_by IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','created_by');
			  Fnd_Msg_Pub.ADD;
		   END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.last_update_login = Fnd_Api.g_miss_num OR
         p_entity_attr_rec.last_update_login IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','last_update_login');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.object_version_number = Fnd_Api.g_miss_num OR p_entity_attr_rec.object_version_number IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','object_version_number');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_entity_attr_rec.attribute_id = Fnd_Api.g_miss_num OR
         p_entity_attr_rec.attribute_id IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','attribute_id');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_entity_attr_rec.entity = Fnd_Api.g_miss_char OR p_entity_attr_rec.entity IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','entity');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.enabled_flag = Fnd_Api.g_miss_char OR p_entity_attr_rec.enabled_flag IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','enabled_flag');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.display_flag = Fnd_Api.g_miss_char OR p_entity_attr_rec.display_flag IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','display_flag');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      /*IF p_entity_attr_rec.auto_assign_flag = Fnd_Api.g_miss_char OR p_entity_attr_rec.auto_assign_flag IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','auto_assign_flag');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      */
   ELSE
      IF p_entity_attr_rec.entity_attr_id IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','entity_attr_id');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.last_update_date IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','last_update_date');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.last_updated_by IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','last_updated_by');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.creation_date IS NULL THEN
		  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','creation_date');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.created_by IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','created_by');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.last_update_login IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','last_update_login');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.object_version_number IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','object_version_number');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.attribute_id IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','attribute_id');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.entity IS NULL THEN
 	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','entity');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.enabled_flag IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','enabled_flag');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      IF p_entity_attr_rec.display_flag IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','display_flag');
			  Fnd_Msg_Pub.ADD;
		  END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      /*IF p_entity_attr_rec.auto_assign_flag IS NULL THEN
	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  Fnd_Message.set_token('COLUMN','auto_assign_flag');
			  Fnd_Msg_Pub.ADD;
		  END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
      */





   END IF;
END check_req_items;

PROCEDURE check_FK_items(
    p_entity_attr_rec IN entity_attr_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;
   -- Enter custom code here
END check_FK_items;

PROCEDURE check_Lookup_items(
    p_entity_attr_rec IN entity_attr_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;
   -- Enter custom code here
END check_Lookup_items;

PROCEDURE Check_Entity_Attr_Items (
     p_entity_attr_rec     IN    entity_attr_rec_type
    ,p_validation_mode        IN    VARCHAR2
    ,x_return_status          OUT NOCOPY   VARCHAR2
    )
IS
 l_api_name    CONSTANT VARCHAR2(30) := 'Check_Entity_Attr_Items';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   -- Check Items Uniqueness API calls

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_uk_items' );

   check_uk_items(
       p_entity_attr_rec  => p_entity_attr_rec
      ,p_validation_mode     => p_validation_mode
      ,x_return_status       => x_return_status
      );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_req_items' );

   check_req_items(
       p_entity_attr_rec  => p_entity_attr_rec
      ,p_validation_mode     => p_validation_mode
      ,x_return_status       => x_return_status
      );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Foreign Keys API calls

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_FK_items' );

   check_FK_items(
      p_entity_attr_rec => p_entity_attr_rec
      ,x_return_status => x_return_status
      );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_Lookup_items' );

   check_Lookup_items(
       p_entity_attr_rec => p_entity_attr_rec
      ,x_return_status => x_return_status
      );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;
END Check_Entity_Attr_Items;

PROCEDURE Complete_entity_attr_rec (
   p_entity_attr_rec IN entity_attr_rec_type
   ,x_complete_rec OUT NOCOPY entity_attr_rec_type)
IS
   l_return_status  VARCHAR2(1);
   CURSOR c_complete IS
      SELECT *
      FROM pv_entity_attrs
      WHERE entity_attr_id = p_entity_attr_rec.entity_attr_id;
   l_entity_attr_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_entity_attr_rec;
   OPEN c_complete;
   FETCH c_complete INTO l_entity_attr_rec;
   CLOSE c_complete;
   -- entity_attr_id
   IF p_entity_attr_rec.entity_attr_id = Fnd_Api.g_miss_num THEN
      x_complete_rec.entity_attr_id := l_entity_attr_rec.entity_attr_id;
   END IF;
   -- last_update_date
   IF p_entity_attr_rec.last_update_date = Fnd_Api.g_miss_date THEN
      x_complete_rec.last_update_date := l_entity_attr_rec.last_update_date;
   END IF;
   -- last_updated_by
   IF p_entity_attr_rec.last_updated_by = Fnd_Api.g_miss_num THEN
      x_complete_rec.last_updated_by := l_entity_attr_rec.last_updated_by;
   END IF;
   -- creation_date
   IF p_entity_attr_rec.creation_date = Fnd_Api.g_miss_date THEN
      x_complete_rec.creation_date := l_entity_attr_rec.creation_date;
   END IF;
   -- created_by
   IF p_entity_attr_rec.created_by = Fnd_Api.g_miss_num THEN
      x_complete_rec.created_by := l_entity_attr_rec.created_by;
   END IF;
   -- last_update_login
   IF p_entity_attr_rec.last_update_login = Fnd_Api.g_miss_num THEN
      x_complete_rec.last_update_login := l_entity_attr_rec.last_update_login;
   END IF;
   -- object_version_number
   IF p_entity_attr_rec.object_version_number = Fnd_Api.g_miss_num THEN
      x_complete_rec.object_version_number := l_entity_attr_rec.object_version_number;
   END IF;
   -- attribute_id
   IF p_entity_attr_rec.attribute_id = Fnd_Api.g_miss_num THEN
      x_complete_rec.attribute_id := l_entity_attr_rec.attribute_id;
   END IF;
   -- entity
   IF p_entity_attr_rec.entity = Fnd_Api.g_miss_char THEN
      x_complete_rec.entity := l_entity_attr_rec.entity;
   END IF;
   /*
   -- src_table_name
   IF p_entity_attr_rec.src_table_name = Fnd_Api.g_miss_char THEN
      x_complete_rec.src_table_name := l_entity_attr_rec.src_table_name;
   END IF;
   -- src_pkcol_name
   IF p_entity_attr_rec.src_pkcol_name = Fnd_Api.g_miss_char THEN
      x_complete_rec.src_pkcol_name := l_entity_attr_rec.src_pkcol_name;
   END IF;
   */
   -- sql_text
   IF p_entity_attr_rec.sql_text = Fnd_Api.g_miss_char THEN
      x_complete_rec.sql_text := l_entity_attr_rec.sql_text;
   END IF;
   -- attr_data_type
   IF p_entity_attr_rec.attr_data_type = Fnd_Api.g_miss_char THEN
      x_complete_rec.attr_data_type := l_entity_attr_rec.attr_data_type;
   END IF;
   -- lov_string
   IF p_entity_attr_rec.lov_string = Fnd_Api.g_miss_char THEN
      x_complete_rec.lov_string := l_entity_attr_rec.lov_string;
   END IF;
   -- enabled_flag
   IF p_entity_attr_rec.enabled_flag = Fnd_Api.g_miss_char THEN
      x_complete_rec.enabled_flag := l_entity_attr_rec.enabled_flag;
   END IF;
   -- item_style
  /* IF p_entity_attr_rec.item_style = Fnd_Api.g_miss_char THEN
      x_complete_rec.item_style := l_entity_attr_rec.item_style;
   END IF;
   -- selection_type
   IF p_entity_attr_rec.selection_type = Fnd_Api.g_miss_char THEN
      x_complete_rec.selection_type := l_entity_attr_rec.selection_type;
   END IF; */
   -- display_flag
   IF p_entity_attr_rec.display_flag = Fnd_Api.g_miss_char THEN
      x_complete_rec.display_flag := l_entity_attr_rec.display_flag;
   END IF;
   /*
   -- rank
   IF p_entity_attr_rec.rank = Fnd_Api.g_miss_num THEN
      x_complete_rec.rank := l_entity_attr_rec.rank;
   END IF;
   -- auto_assign_flag
   IF p_entity_attr_rec.auto_assign_flag = Fnd_Api.g_miss_char THEN
      x_complete_rec.auto_assign_flag := l_entity_attr_rec.auto_assign_flag;
   END IF;
   */
   -- security_group_id
   --IF p_entity_attr_rec.security_group_id = FND_API.g_miss_num THEN
   --   x_complete_rec.security_group_id := l_entity_attr_rec.security_group_id;
   --END IF;
   -- locator_flag
   IF p_entity_attr_rec.locator_flag = Fnd_Api.g_miss_char THEN
      x_complete_rec.locator_flag := l_entity_attr_rec.locator_flag;
   END IF;
    -- require_validation_flag
   IF p_entity_attr_rec.require_validation_flag = Fnd_Api.g_miss_char THEN
      x_complete_rec.require_validation_flag := l_entity_attr_rec.require_validation_flag;
   END IF;

	 -- external_update_text
   IF p_entity_attr_rec.external_update_text = Fnd_Api.g_miss_char THEN
      x_complete_rec.external_update_text := l_entity_attr_rec.external_update_text;
   END IF;


 -- refresh_frequency
   IF p_entity_attr_rec.refresh_frequency = Fnd_Api.g_miss_num THEN
      x_complete_rec.refresh_frequency := l_entity_attr_rec.refresh_frequency;
   END IF;


    -- refresh_frequency_uom
   IF p_entity_attr_rec.refresh_frequency_uom = Fnd_Api.g_miss_char THEN
      x_complete_rec.refresh_frequency_uom := l_entity_attr_rec.refresh_frequency_uom;
   END IF;

  -- batch_sql_text
   IF p_entity_attr_rec.batch_sql_text = Fnd_Api.g_miss_char THEN
      x_complete_rec.batch_sql_text := l_entity_attr_rec.batch_sql_text;
   END IF;
     -- last_refresh_date
   IF p_entity_attr_rec.last_refresh_date = Fnd_Api.g_miss_date THEN
      x_complete_rec.last_refresh_date := l_entity_attr_rec.last_refresh_date;
   END IF;
-- batch_sql_text
   IF p_entity_attr_rec.display_external_value_flag = Fnd_Api.g_miss_char THEN
      x_complete_rec.display_external_value_flag := l_entity_attr_rec.display_external_value_flag;
   END IF;



   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_entity_attr_rec;

PROCEDURE Validate_Entity_Attr(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,p_validation_mode            IN   VARCHAR2     := Jtf_Plsql_Api.G_UPDATE
    ,p_entity_attr_rec         IN   entity_attr_rec_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_Entity_Attr';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_object_version_number     NUMBER;
l_entity_attr_rec        Pv_Entity_Attribute_Pvt.entity_attr_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Validate_Entity_Attr_;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;

      IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before Check_Entity_Attr_Items' );

              Check_Entity_Attr_Items(
                  p_entity_attr_rec    => p_entity_attr_rec
                 ,p_validation_mode       => p_validation_mode
                 ,x_return_status         => x_return_status
                 );

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Check_Entity_Attr_Items' );

              IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
                  RAISE Fnd_Api.G_EXC_ERROR;
              ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
                  RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_entity_attr_rec(
         p_entity_attr_rec        => p_entity_attr_rec
         ,x_complete_rec             => l_entity_attr_rec
      );
      IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
         Validate_Entity_Attr_Rec(
            p_api_version_number     => 1.0
           ,p_init_msg_list          => Fnd_Api.G_FALSE
           ,x_return_status          => x_return_status
           ,x_msg_count              => x_msg_count
           ,x_msg_data               => x_msg_data
           ,p_entity_attr_rec           =>    l_entity_attr_rec
           );
              IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
                 RAISE Fnd_Api.G_EXC_ERROR;
              ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
                 RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;
      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
	  END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      -- Debug Message
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
	  END IF;
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count
         ,p_data           =>   x_msg_data
      );
EXCEPTION
/*
   WHEN PV_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PV_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
*/
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO Validate_Entity_Attr_;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_Entity_Attr_;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_Entity_Attr_;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );
END Validate_Entity_Attr;


PROCEDURE Validate_Entity_Attr_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_entity_attr_rec         IN   entity_attr_rec_type
    ,p_validation_mode            IN   VARCHAR2     := Jtf_Plsql_Api.G_UPDATE
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  Pvx_Utility_Pvt.debug_message('Private API: Validate_dm_model_rec');
	  END IF;

      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get (
         p_count          =>   x_msg_count
        ,p_data           =>   x_msg_data
        );
END Validate_Entity_Attr_Rec;

END Pv_Entity_Attribute_Pvt;

/
