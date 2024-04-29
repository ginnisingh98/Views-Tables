--------------------------------------------------------
--  DDL for Package Body PV_ATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTRIBUTE_PVT" as
/* $Header: pvxvatsb.pls 120.4 2008/01/04 05:13:33 abnagapp ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Attribute_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Attribute_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvatsb.pls';

G_USER_ID         NUMBER := NVL(FND_GLOBAL.USER_ID, -1);
G_LOGIN_ID        NUMBER := NVL(FND_GLOBAL.CONC_LOGIN_ID, -1);

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Attribute(
     p_api_version_number        IN   NUMBER
    ,p_init_msg_list             IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                    IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level          IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                 OUT NOCOPY  NUMBER
    ,x_msg_data                  OUT NOCOPY  VARCHAR2

    ,p_attribute_rec             IN   attribute_rec_type  := g_miss_attribute_rec
    ,x_attribute_id              OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Attribute';
   L_FULL_NAME                 CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_ATTRIBUTE_ID              NUMBER;
   l_dummy                     NUMBER;
   l_attribute_rec             attribute_rec_type  := p_attribute_rec;
   l_meaning					VARCHAR2(80);

   CURSOR c_id IS
      SELECT PV_ATTRIBUTES_B_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_ATTRIBUTES_B
      WHERE ATTRIBUTE_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Attribute_PVT;

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
      --DBMS_output.put_line('Private API: ' || L_FULL_NAME || ' start');
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: ' || L_FULL_NAME || ' start');
	  end if;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_attribute_rec.ATTRIBUTE_ID IS NULL OR p_attribute_rec.ATTRIBUTE_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_ATTRIBUTE_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_ATTRIBUTE_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;

   ELSE
      l_ATTRIBUTE_ID := p_attribute_rec.ATTRIBUTE_ID;
   END IF;


      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
         FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		  PVX_UTILITY_PVT.debug_message('Private API: Validate_Attribute');
		  END IF;

          --DBMS_output.put_line('Before validate_attribute');

	   -- Populate the default required items
           l_attribute_rec.attribute_id          := l_attribute_id;
           l_attribute_rec.last_update_date      := SYSDATE;
           l_attribute_rec.last_updated_by       := G_USER_ID;
           l_attribute_rec.creation_date         := SYSDATE;
           l_attribute_rec.created_by            := G_USER_ID;
           l_attribute_rec.last_update_login     := G_LOGIN_ID;
           l_attribute_rec.object_version_number := l_object_version_number;

          -- Invoke validation procedures
          Validate_attribute(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_validation_mode        => JTF_PLSQL_API.g_create,
            p_attribute_rec          => l_attribute_rec,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      --check for attribute types
      IF((l_attribute_rec.attribute_type = 'TEXT' and l_attribute_rec.display_style not in ('CURRENCY','DATE','NUMBER','STRING','NULL_CHECK','PERCENTAGE')) OR
         (l_attribute_rec.attribute_type = 'DROPDOWN' and l_attribute_rec.display_style not in ('CHECK','MULTI','RADIO','SINGLE','EXTERNAL_LOV','PERCENTAGE')) OR
	 (l_attribute_rec.attribute_type = 'FUNCTION' and l_attribute_rec.display_style not in ('NUMBER','STRING','LOV','DATE','CURRENCY','PERCENTAGE'))
        ) THEN

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			FND_MESSAGE.Set_Name('PV', 'PV_ATTR_TYPE_STYLE_NOT_CREATE');

			FOR x IN (select meaning from pv_lookups
				    where lookup_type = 'PV_ATTRIBUTE_TYPE'
				    and lookup_code = l_attribute_rec.attribute_type
				   ) LOOP
				l_meaning := x.meaning;
			END LOOP;
			Fnd_Message.set_token('ATTRIBUTE_TYPE',l_meaning);

			FOR x IN (select meaning from pv_lookups
				    where lookup_type = 'PV_ATTR_DISPLAY_STYLE'
				    and lookup_code = l_attribute_rec.display_style
				   ) LOOP
				l_meaning := x.meaning;
			END LOOP;
			FND_MESSAGE.Set_Token('DISPLAY_STYLE',l_meaning );
			FND_MSG_PUB.Add;
		END IF;

		RAISE FND_API.G_EXC_ERROR;

	END IF;


      --end of check for attributes tyupes and display styles




      -- Debug Message
      PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(PV_ATTRIBUTE_PKG.Insert_Row)
      PV_ATTRIBUTE_PKG.Insert_Row(
          px_attribute_id           => l_attribute_rec.attribute_id,
          p_last_update_date        => l_attribute_rec.last_update_date,
          p_last_updated_by         => l_attribute_rec.last_updated_by,
          p_creation_date           => l_attribute_rec.creation_date,
          p_created_by              => l_attribute_rec.created_by,
          p_last_update_login       => l_attribute_rec.last_update_login,
          px_object_version_number  => l_attribute_rec.object_version_number,
          --p_security_group_id     => l_attribute_rec.security_group_id,
          p_enabled_flag            => l_attribute_rec.enabled_flag,
          p_attribute_type          => l_attribute_rec.attribute_type,
          p_attribute_category      => l_attribute_rec.attribute_category,
          p_seeded_flag             => l_attribute_rec.seeded_flag,
          p_lov_function_name       => l_attribute_rec.lov_function_name,
          p_return_type             => l_attribute_rec.return_type,
          p_max_value_flag          => l_attribute_rec.max_value_flag,
	  p_name                    => l_attribute_rec.name,
	  p_description             => l_attribute_rec.description,
	  p_short_name              => l_attribute_rec.short_name,

	  p_display_style	    => l_attribute_rec.display_style,
          p_character_width	    => l_attribute_rec.character_width,
          p_decimal_points    	    => l_attribute_rec.decimal_points,
          p_no_of_lines		    => l_attribute_rec.no_of_lines,
          p_expose_to_partner_flag  => l_attribute_rec.expose_to_partner_flag,
          p_value_extn_return_type  => l_attribute_rec.value_extn_return_type,
	  p_enable_matching_flag    => l_attribute_rec.enable_matching_flag,
	  p_performance_flag        => l_attribute_rec.performance_flag,
	  p_additive_flag	    => l_attribute_rec.additive_flag,
	  p_sequence_number	    => l_attribute_rec.sequence_number

	  );


          x_attribute_id := l_attribute_id;

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
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: ' || L_FULL_NAME || 'end');
	  END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

/*
   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Attribute_PVT;
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
End Create_Attribute;


PROCEDURE Update_Attribute(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN  NUMBER        := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attribute_rec              IN    attribute_rec_type
    ,x_object_version_number      OUT NOCOPY  NUMBER

    )

 IS

CURSOR c_get_attribute(cv_attribute_id NUMBER) IS
    SELECT *
    FROM  PV_ATTRIBUTES_B
    where attribute_id = cv_attribute_id;

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Attribute';
   L_FULL_NAME                 CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_object_version_number     NUMBER;
   l_ATTRIBUTE_ID    NUMBER;
   l_ref_attribute_rec  c_get_Attribute%ROWTYPE ;
   l_tar_attribute_rec  PV_Attribute_PVT.attribute_rec_type := P_attribute_rec;
   l_rowid  ROWID;

   l_being_used_list	    VARCHAR2(30000);
   l_delete_flag	    VARCHAR2(1):='Y';
   l_meaning		    VARCHAR2(80);
   l_sequence_number        NUMBER;

cursor lc_check_rules (pc_attribute_id number) is
   select  distinct rules.process_rule_name
   from pv_enty_select_criteria criteria,pv_process_rules_vl rules
   where criteria.attribute_id= pc_attribute_id
         and criteria.process_rule_id= rules.process_rule_id;

cursor lc_check_matching (pc_attribute_id number) is
	select resp.RESPONSIBILITY_NAME
	from pv_attrib_resp_mappings val, FND_RESPONSIBILITY_VL resp
	where
	val.attribute_id= pc_attribute_id and
	resp.application_id = 691 and
	val.entity_type = 'MANUAL_MATCHING' and
	resp.RESPONSIBILITY_ID = val.responsibility_id;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Attribute_PVT;

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
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: ' || L_FULL_NAME || 'start');
	  END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
	  END IF;



      OPEN c_get_Attribute( l_tar_attribute_rec.attribute_id);

      FETCH c_get_Attribute INTO l_ref_attribute_rec  ;

      IF ( c_get_Attribute%NOTFOUND) THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
			 FND_MESSAGE.set_token('MODE','Update');
			 FND_MESSAGE.set_token('ENTITY','Attribute');
			 FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_attribute_rec.attribute_id));
			 FND_MSG_PUB.add;
		 END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
      END IF;
	  CLOSE     c_get_Attribute;






      --check it is updatable or not by checkiong rules reference

      if(l_ref_attribute_rec.enabled_flag = 'Y' and p_attribute_rec.enabled_flag= 'N') then

			for x in lc_check_rules (pc_attribute_id =>p_attribute_rec.attribute_id)
			loop
				l_delete_flag := 'N' ;
				l_being_used_list := l_being_used_list || ','|| x.process_rule_name ;
			end loop;


            if(l_delete_flag = 'N') then

				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
					FND_MESSAGE.Set_Name('PV', 'PV_ATTR_NOTDISABLED_RULE');
					FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',p_attribute_rec.name );
					FND_MESSAGE.Set_Token('RULES_LIST',substr(l_being_used_list,2) );
					FND_MSG_PUB.Add;
				END IF;

				RAISE FND_API.G_EXC_ERROR;

			end if;

			--check it is updatable or not by checkiong matching reference

			for x in lc_check_matching (pc_attribute_id =>p_attribute_rec.attribute_id)
			loop
				l_delete_flag := 'N' ;
				l_being_used_list := l_being_used_list || ','|| x.RESPONSIBILITY_NAME ;
			end loop;


            if(l_delete_flag = 'N') then

				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
					FND_MESSAGE.Set_Name('PV', 'PV_ATTR_NOTDISABLED_MATCHING');
					FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',p_attribute_rec.name );
					FND_MESSAGE.Set_Token('RESPONSIBILITY_LIST',substr(l_being_used_list,2) );
					FND_MSG_PUB.Add;
				END IF;

				RAISE FND_API.G_EXC_ERROR;

			end if;
      end if;

     --check max_value_flag is updatable or not by checkiong rules reference
	  if(l_ref_attribute_rec.max_value_flag <> p_attribute_rec.max_value_flag) then

			for x in lc_check_rules (pc_attribute_id =>p_attribute_rec.attribute_id)
			loop
				l_delete_flag := 'N' ;
				l_being_used_list := l_being_used_list || ','|| x.process_rule_name ;
			end loop;


            if(l_delete_flag = 'N') then

				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
					FND_MESSAGE.Set_Name('PV', 'PV_VALUE_TYPE_REFERENCED_RULE');
					FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',p_attribute_rec.name );
					FND_MESSAGE.Set_Token('RULES_LIST',substr(l_being_used_list,2) );
					FND_MSG_PUB.Add;
				END IF;

				RAISE FND_API.G_EXC_ERROR;

			end if;
		end if;

		 --check ENABLE_MATCHING_FLAG is updatable or not by checkiong rules reference and manual matching reference
	 -- if(l_ref_attribute_rec.enable_matching_flag <> p_attribute_rec.enable_matching_flag) then
      if(l_ref_attribute_rec.enable_matching_flag = 'Y' and p_attribute_rec.enable_matching_flag= 'N') then
			for x in lc_check_rules (pc_attribute_id =>p_attribute_rec.attribute_id)
			loop
				l_delete_flag := 'N' ;
				l_being_used_list := l_being_used_list || ','|| x.process_rule_name ;
			end loop;


            if(l_delete_flag = 'N') then

				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
					FND_MESSAGE.Set_Name('PV', 'PV_MATCHING_REFERENCED_RULE');
					FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',p_attribute_rec.name );
					FND_MESSAGE.Set_Token('RULES_LIST',substr(l_being_used_list,2) );
					FND_MSG_PUB.Add;
				END IF;

				RAISE FND_API.G_EXC_ERROR;

			end if;

			for x in lc_check_matching (pc_attribute_id =>p_attribute_rec.attribute_id)
			loop
				l_delete_flag := 'N' ;
				l_being_used_list := l_being_used_list || ','|| x.RESPONSIBILITY_NAME ;
			end loop;


            if(l_delete_flag = 'N') then

				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
					FND_MESSAGE.Set_Name('PV', 'PV_MATCHING_NOTDISABLED');
					FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',p_attribute_rec.name );
					FND_MESSAGE.Set_Token('RESPONSIBILITY_LIST',substr(l_being_used_list,2) );
					FND_MSG_PUB.Add;
				END IF;

				RAISE FND_API.G_EXC_ERROR;

			end if;

		end if;

	--for bug#  3397200, restricting partner type display style changes
	--for bug 6723524, commenting the code as partner type cannot
	--be changed from the ui itself. So this if block is of no use.

	--if(p_attribute_rec.attribute_type is not null and
	--   p_attribute_rec.display_style is not null and
	--   p_attribute_rec.attribute_id = 3 and
	--   l_ref_attribute_rec.display_style in ('SINGLE') and
	--   p_attribute_rec.display_style  in ('SINGLE')
	--   )
	--  THEN
	--	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN

	--		FND_MESSAGE.set_name('PV', 'PV_ATTR_NOT_CHANGE_STYLE');
	--		FND_MESSAGE.set_token('NAME',p_attribute_rec.name);

	--		FOR x IN (select meaning from pv_lookups
	--			where lookup_type = 'PV_ATTRIBUTE_TYPE'
	--			and lookup_code = p_attribute_rec.attribute_type
	--		) LOOP
	--			l_meaning := x.meaning;
	--		END LOOP;
	--		Fnd_Message.set_token('TYPE',l_meaning);

	--		FOR x IN (select meaning from pv_lookups
	--			where lookup_type = 'PV_ATTR_DISPLAY_STYLE'
	--			and lookup_code = l_ref_attribute_rec.display_style
	--		) LOOP
	--			l_meaning := x.meaning;
	--		END LOOP;
	--		FND_MESSAGE.set_token('FROM',l_meaning);

	--		FOR x IN (select meaning from pv_lookups
	--			where lookup_type = 'PV_ATTR_DISPLAY_STYLE'
	--			and lookup_code = p_attribute_rec.display_style
	--		) LOOP
	--			l_meaning := x.meaning;
	--		END LOOP;

	--		FND_MESSAGE.set_token('TO',l_meaning);
	--		FND_MSG_PUB.add;

	--	END IF;
	--	RAISE FND_API.G_EXC_ERROR;


	--   end if;

	-- end of change for bug# 6723524
	-- end of  change for bug#  3397200, restricting partner type display style changes


	  --Check whether conversion of display_styles is ok or not

	  if(p_attribute_rec.attribute_type is not null and p_attribute_rec.display_style is not null and
	     (
			 (p_attribute_rec.attribute_type in ('TEXT','FUNCTION') and  l_ref_attribute_rec.display_style <> p_attribute_rec.display_style) or
			 (p_attribute_rec.attribute_type in ('DROPDOWN') and l_ref_attribute_rec.display_style in ('PERCENTAGE') and  p_attribute_rec.display_style not in ('PERCENTAGE')) or
			 (p_attribute_rec.attribute_type in ('DROPDOWN') and l_ref_attribute_rec.display_style not in ('PERCENTAGE') and  p_attribute_rec.display_style in ('PERCENTAGE')) or
			 (p_attribute_rec.attribute_type in ('DROPDOWN') and l_ref_attribute_rec.display_style in ('SINGLE','RADIO') and  p_attribute_rec.display_style not in ('SINGLE','RADIO')) or
			 (p_attribute_rec.attribute_type in ('DROPDOWN') and l_ref_attribute_rec.display_style not in ('SINGLE','RADIO') and  p_attribute_rec.display_style in ('SINGLE','RADIO')) or
			 (p_attribute_rec.attribute_type in ('DROPDOWN') and l_ref_attribute_rec.display_style in ('MULTI','CHECK') and  p_attribute_rec.display_style not in ('MULTI','CHECK')) or
			 (p_attribute_rec.attribute_type in ('DROPDOWN') and l_ref_attribute_rec.display_style not in ('MULTI','CHECK') and  p_attribute_rec.display_style in ('MULTI','CHECK'))
		 )


		) THEN

				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN

					/*FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
					FND_MESSAGE.set_token('TEXT', 'Can not :' || p_attribute_rec.attribute_type || ':' ||
					l_ref_attribute_rec.display_style || ':' ||p_attribute_rec.display_style ||':');
					FND_MSG_PUB.add;
					*/

					FND_MESSAGE.set_name('PV', 'PV_ATTR_NOT_CHANGE_STYLE');
					FND_MESSAGE.set_token('NAME',p_attribute_rec.name);

					FOR x IN (select meaning from pv_lookups
						where lookup_type = 'PV_ATTRIBUTE_TYPE'
						and lookup_code = p_attribute_rec.attribute_type
					) LOOP
						l_meaning := x.meaning;
					END LOOP;
					Fnd_Message.set_token('TYPE',l_meaning);

					FOR x IN (select meaning from pv_lookups
						where lookup_type = 'PV_ATTR_DISPLAY_STYLE'
						and lookup_code = l_ref_attribute_rec.display_style
					) LOOP
						l_meaning := x.meaning;
					END LOOP;
					FND_MESSAGE.set_token('FROM',l_meaning);

					FOR x IN (select meaning from pv_lookups
						where lookup_type = 'PV_ATTR_DISPLAY_STYLE'
						and lookup_code = p_attribute_rec.display_style
					) LOOP
						l_meaning := x.meaning;
					END LOOP;

					FND_MESSAGE.set_token('TO',l_meaning);
					FND_MSG_PUB.add;

				END IF;
				RAISE FND_API.G_EXC_ERROR;



	  END IF;

     --for bug#5148569, while updatring attribute category, resetting the sequence_numbe.
     if(l_ref_attribute_rec.attribute_category <> p_attribute_rec.attribute_category) then
        l_sequence_number := null;
     else
        l_sequence_number := p_attribute_rec.sequence_number;
     end if;



      If (l_tar_attribute_rec.object_version_number is NULL or
          l_tar_attribute_rec.object_version_number = FND_API.G_MISS_NUM ) Then

		   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
			   FND_MESSAGE.set_token('COLUMN', TO_CHAR(l_tar_attribute_rec.last_update_date));
			   FND_MSG_PUB.add;
		   END IF;
           RAISE FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_attribute_rec.object_version_number <> l_ref_attribute_rec.object_version_number) Then
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
			   FND_MESSAGE.set_token('VALUE','Attribute');
			   FND_MSG_PUB.add;
		   END IF;
           RAISE FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		  PVX_UTILITY_PVT.debug_message('Private API: Validate_Attribute');
		  END IF;
          --dbms_output.put_line('Before Validate_attribute');
          -- Invoke validation procedures
          Validate_attribute(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_validation_mode        => JTF_PLSQL_API.g_update,
            p_attribute_rec          => p_attribute_rec,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);
      END IF;


      --DBMS_output.put_line('Before update_row');

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	  RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
      PVX_UTILITY_PVT.debug_message('Private API: '||l_full_name||' - Calling update table handler');
	  END IF;

      --DBMS_output.put_line('Before update_row');

      -- Invoke table handler(PV_ATTRIBUTE_PKG.Update_Row)
      PV_ATTRIBUTE_PKG.Update_Row(
          p_attribute_id            => p_attribute_rec.attribute_id,
          p_last_update_date        => SYSDATE,
          p_last_updated_by         => G_USER_ID,
          --p_creation_date         => SYSDATE,
          --p_created_by            => G_USER_ID,
          p_last_update_login       => G_LOGIN_ID,
          p_object_version_number   => p_attribute_rec.object_version_number,
          --p_security_group_id     => p_attribute_rec.security_group_id,
          p_enabled_flag            => p_attribute_rec.enabled_flag,
          p_attribute_type          => p_attribute_rec.attribute_type,
          p_attribute_category      => p_attribute_rec.attribute_category,
          p_seeded_flag             => p_attribute_rec.seeded_flag,
          p_lov_function_name       => p_attribute_rec.lov_function_name,
          p_return_type             => p_attribute_rec.return_type,
          p_max_value_flag          => p_attribute_rec.max_value_flag,
          p_name                    => p_attribute_rec.name,
          p_description             => p_attribute_rec.description,
          p_short_name              => p_attribute_rec.short_name,


	      p_display_style	    => p_attribute_rec.display_style,
          p_character_width	    => p_attribute_rec.character_width,
          p_decimal_points    	    => p_attribute_rec.decimal_points,
          p_no_of_lines		    => p_attribute_rec.no_of_lines,
          p_expose_to_partner_flag  => p_attribute_rec.expose_to_partner_flag,
          p_value_extn_return_type  => p_attribute_rec.value_extn_return_type,
	  p_enable_matching_flag    => p_attribute_rec.enable_matching_flag,
	  p_performance_flag	    => p_attribute_rec.performance_flag,
	  p_additive_flag	    => p_attribute_rec.additive_flag,
	  p_sequence_number	    => l_sequence_number

	  );

          x_object_version_number := p_attribute_rec.object_version_number+1;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: ' || L_FULL_NAME || 'end');
	  END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

/*
   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Attribute_PVT;
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
End Update_Attribute;


PROCEDURE Delete_Attribute(
     p_api_version_number        IN   NUMBER
    ,p_init_msg_list             IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                    IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level          IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                 OUT NOCOPY  NUMBER
    ,x_msg_data                  OUT NOCOPY  VARCHAR2
    ,p_attribute_id              IN   NUMBER
    ,p_object_version_number     IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Attribute';
L_FULL_NAME                 CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_attribute_name            VARCHAR2(60);

l_being_used_list	    VARCHAR2(30000);
l_delete_flag	            VARCHAR2(1):='Y';
l_meaning					VARCHAR2(80);
cursor lc_get_attr_details (pc_attribute_id number) is
   select name
   from pv_attributes_vl
   where attribute_id = pc_attribute_id;

cursor lc_check_attr_enty_vals (pc_attribute_id number) is
   select distinct entity
   from pv_enty_attr_values
   where attribute_id = pc_attribute_id;

cursor lc_check_rules (pc_attribute_id number) is
   select  distinct rules.process_rule_name
   from pv_enty_select_criteria criteria,pv_process_rules_vl rules
   where criteria.attribute_id= pc_attribute_id
         and criteria.process_rule_id= rules.process_rule_id;

cursor lc_check_matching (pc_attribute_id number) is
	select resp.RESPONSIBILITY_NAME
	from pv_attrib_resp_mappings val, FND_RESPONSIBILITY_VL resp
	where
	val.attribute_id= pc_attribute_id and
	resp.application_id = 691 and
	val.entity_type = 'MANUAL_MATCHING' and
	resp.RESPONSIBILITY_ID = val.responsibility_id;

cursor lc_check_resp_mappings (pc_attribute_id number) is

	select resp.RESPONSIBILITY_NAME, lkp.meaning
	from pv_attrib_resp_mappings val,
	FND_RESPONSIBILITY_VL resp,
	pv_lookups lkp
	where
	val.attribute_id= pc_attribute_id and
	resp.RESPONSIBILITY_ID = val.responsibility_id and
        resp.application_id = 691 and
	val.entity_type = lkp.lookup_code and
	lkp.lookup_type='PV_ATTR_RESP_MAPPING_ENTITIES';


cursor lc_check_seeded_attr (pc_attribute_id number) is
   select  seeded_flag
   from pv_attributes_vl
   where attribute_id = pc_attribute_id;

cursor lc_entity_attrs (pc_attribute_id number) is
   select  entity_attr_id
   from pv_entity_attrs
   where attribute_id = pc_attribute_id;

cursor lc_attribute_usages (pc_attribute_id number) is
   select  attribute_usage_id
   from pv_attribute_usages
   where attribute_id = pc_attribute_id;

cursor lc_attribute_codes (pc_attribute_id number) is
   select attr_code_id
   from PV_ATTRIBUTE_CODES_vl
   where attribute_id = pc_attribute_id;


BEGIN
      --DBMS_output.put_line('Begin Delete_attribute');

      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Attribute_PVT;

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
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: ' || L_FULL_NAME || ' start');
	  END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message

      --checking whether this ttribute is being referenced by any entity, rule, manual_matching

      --First get Attribute Name
      open lc_get_attr_details (pc_attribute_id =>p_attribute_id);
      fetch lc_get_attr_details into l_attribute_name;
      close lc_get_attr_details;

      --check for seeded attr

     for x in lc_check_seeded_attr (pc_attribute_id =>p_attribute_id)
     loop
			if( x.seeded_flag = 'Y') then
				l_delete_flag :='N';
			end if;
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN

				FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
				FND_MESSAGE.set_token('TEXT', 'Is it Seeded '|| x.seeded_flag);
			    FND_MSG_PUB.add;

            END IF;
      end loop;


      if(l_delete_flag = 'N') then

			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR))
			THEN
				FND_MESSAGE.Set_Name('PV', 'PV_ATTR_REFERENCED_SEEDED');
				FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',l_attribute_name );

				FND_MSG_PUB.Add;
			END IF;

			RAISE FND_API.G_EXC_ERROR;

      end if;

      --check for entity reference

      for x in lc_check_attr_enty_vals (pc_attribute_id =>p_attribute_id)
      loop
        l_delete_flag := 'N';

	FOR y IN (select meaning from pv_lookups
		    where lookup_type = 'PV_VALID_ENTY_VALUE_TYPES'
		    and lookup_code = x.entity
		   ) LOOP
		l_meaning := y.meaning;
	END LOOP;


	l_being_used_list := l_being_used_list || ','|| l_meaning ;
	l_meaning := '';

      end loop;

		  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN

              FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
			  FND_MESSAGE.set_token('TEXT', 'Entity List '|| l_being_used_list);
			  FND_MSG_PUB.add;
          END IF;

      if(l_delete_flag = 'N') then

		  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR))
	      THEN
              FND_MESSAGE.Set_Name('PV', 'PV_ATTR_REFERENCED_ENTITY');
              FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',l_attribute_name );
			  FND_MESSAGE.Set_Token('ENTITY_LIST',substr(l_being_used_list,2) );
              FND_MSG_PUB.Add;
          END IF;

        RAISE FND_API.G_EXC_ERROR;

      end if;

      --check for rule reference

     for x in lc_check_rules (pc_attribute_id =>p_attribute_id)
     loop
		l_delete_flag := 'N' ;
		l_being_used_list := l_being_used_list || ','|| x.process_rule_name ;
     end loop;


     if(l_delete_flag = 'N') then

		 IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR))
		 THEN
			FND_MESSAGE.Set_Name('PV', 'PV_ATTR_REFERENCED_RULE');
			FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',l_attribute_name );
			FND_MESSAGE.Set_Token('RULES_LIST',substr(l_being_used_list,2) );
			FND_MSG_PUB.Add;
		 END IF;

		 RAISE FND_API.G_EXC_ERROR;

     end if;

      --check for manual matching reference

	for x in lc_check_matching (pc_attribute_id =>p_attribute_id)
     loop
		l_delete_flag := 'N' ;
		l_being_used_list := l_being_used_list || ','|| x.RESPONSIBILITY_NAME ;
     end loop;


     if(l_delete_flag = 'N') then

		 IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR))
		 THEN
			FND_MESSAGE.Set_Name('PV', 'PV_ATTR_REFERENCED_MATCHING');
			FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',l_attribute_name );
			FND_MESSAGE.Set_Token('RESPONSIBILITY_LIST',substr(l_being_used_list,2) );
			FND_MSG_PUB.Add;
		 END IF;

		 RAISE FND_API.G_EXC_ERROR;

     end if;

	 --check for responsibilites mappings reference

	for x in lc_check_resp_mappings (pc_attribute_id =>p_attribute_id)
	loop
		l_delete_flag := 'N' ;
		l_being_used_list := l_being_used_list || ','|| '(' || x.RESPONSIBILITY_NAME || ' ,' || x.meaning || ')';
	end loop;


	if(l_delete_flag = 'N') then

		 IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR))
		 THEN
			FND_MESSAGE.Set_Name('PV', 'PV_ATTR_REFERENCED_RESP_MAP');
			FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',l_attribute_name );
			FND_MESSAGE.Set_Token('MAP_LIST',substr(l_being_used_list,2) );
			FND_MSG_PUB.Add;
		 END IF;

		 RAISE FND_API.G_EXC_ERROR;

	end if;





      --start deleting
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
      PVX_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
	  END IF;


     --delete all rows from pv_attr_codes table

     for x in lc_attribute_codes (pc_attribute_id =>p_attribute_id)
      loop
        IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_UTILITY_PVT.debug_message( 'Calling PV_ATTRIBUTE_CODE_PVT.Delete_Attribute_Code for : ' ||x.attr_code_id );
		END IF;

	PV_ATTRIBUTE_CODE_PVT.Delete_Attribute_Code(
		 p_api_version_number   =>   p_api_version_number
		,p_init_msg_list	=>   p_init_msg_list
		,p_commit               =>   p_commit
		,p_validation_level     =>   p_validation_level

		,x_return_status        =>   x_return_status
		,x_msg_count            =>   x_msg_count
		,x_msg_data             =>   x_msg_data

		,p_attr_code_id         =>   x.attr_code_id
		,p_object_version_number=>   p_object_version_number
		);

      end loop;

      --delete all rows from pv_attribute_usages table

     for x in lc_attribute_usages (pc_attribute_id =>p_attribute_id)
      loop

	PVX_UTILITY_PVT.debug_message( 'Calling PV_Attribute_Usage_PVT.Delete_Attribute_Usage for : ' ||x.attribute_usage_id );
	PV_Attribute_Usage_PVT.Delete_Attribute_Usage(
		 p_api_version_number   =>   p_api_version_number
		,p_init_msg_list	=>   p_init_msg_list
		,p_commit               =>   p_commit
		,p_validation_level     =>   p_validation_level

		,x_return_status        =>   x_return_status
		,x_msg_count            =>   x_msg_count
		,x_msg_data             =>   x_msg_data

		,p_attribute_usage_id   =>   x.attribute_usage_id
		,p_object_version_number=>   p_object_version_number
		);

      end loop;


      --delete all rows from pv_entity_attrs table

     for x in lc_entity_attrs (pc_attribute_id =>p_attribute_id)
      loop

	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message( 'Calling PV_Entity_Attribute_Pvt.Delete_Entity_Attr for : ' ||x.entity_attr_id );
	  END IF;
	PV_Entity_Attribute_Pvt.Delete_Entity_Attr(
		 p_api_version_number   =>   p_api_version_number
		,p_init_msg_list	=>   p_init_msg_list
		,p_commit               =>   p_commit
		,p_validation_level     =>   p_validation_level

		,x_return_status        =>   x_return_status
		,x_msg_count            =>   x_msg_count
		,x_msg_data             =>   x_msg_data

		,p_entity_attr_id	=>   x.entity_attr_id
		,p_object_version_number=>   p_object_version_number
		);
      end loop;

      -- Invoke table handler(PV_ATTRIBUTE_PKG.Delete_Row)

      PV_ATTRIBUTE_PKG.Delete_Row(
          p_ATTRIBUTE_ID  => p_ATTRIBUTE_ID);
      --
      -- End of API body
      --


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: ' || L_FULL_NAME || 'end');
	  END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

/*
   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Attribute_PVT;
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
End Delete_Attribute;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Attribute(
     p_api_version_number        IN   NUMBER
    ,p_init_msg_list             IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                 OUT NOCOPY  NUMBER
    ,x_msg_data                  OUT NOCOPY  VARCHAR2

    ,p_attribute_id              IN  NUMBER
    ,p_object_version            IN  NUMBER

    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Attribute';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_ATTRIBUTE_ID                  NUMBER;

CURSOR c_Attribute IS
   SELECT ATTRIBUTE_ID
   FROM PV_ATTRIBUTES_B
   WHERE ATTRIBUTE_ID = p_ATTRIBUTE_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: ' || L_FULL_NAME || 'start');
	  END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------

  PVX_UTILITY_PVT.debug_message(l_full_name||': start');
  OPEN c_Attribute;

  FETCH c_Attribute INTO l_ATTRIBUTE_ID;

  IF (c_Attribute%NOTFOUND) THEN
    CLOSE c_Attribute;
    IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
       FND_MESSAGE.set_name('PV', 'PV_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Attribute;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  PVX_UTILITY_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Attribute_PVT;
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
End Lock_Attribute;


PROCEDURE check_uk_items(
    p_attribute_rec               IN   attribute_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag     VARCHAR2(1);
l_valid_tl_flag  VARCHAR2(1);

 cursor lc_get_attr_name  is
   select  name from pv_attributes_tl;


BEGIN

      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'PV_ATTRIBUTES_B',
         'ATTRIBUTE_ID = ''' || p_attribute_rec.ATTRIBUTE_ID ||''''
         );
      ELSE
         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'PV_ATTRIBUTES_B',
         'ATTRIBUTE_ID = ''' || p_attribute_rec.ATTRIBUTE_ID ||
         ''' AND ATTRIBUTE_ID <> ' || p_attribute_rec.ATTRIBUTE_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
			  FND_MESSAGE.set_token('ID',to_char(p_attribute_rec.ATTRIBUTE_ID) );
			  FND_MESSAGE.set_token('ENTITY','Attribute');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;



	   --    Added for Bug # 2480199 Begin

	  --check for  uniqueness of attribute_code

	   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
		   for x in lc_get_attr_name
		   loop
				if (UPPER(p_attribute_rec.name)=UPPER(x.name)) then
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN

						FND_MESSAGE.set_name('PV', 'PV_DUPLICATE_RECORD');
						--FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
						--FND_MESSAGE.set_token('ID',to_char(p_attribute_rec.ATTRIBUTE_ID) || ':::' || p_attribute_rec.name);
						--FND_MESSAGE.set_token('ENTITY','Attribute');
						FND_MSG_PUB.add;
					END IF;
					--x_return_status := FND_API.g_ret_sts_error;
					RAISE FND_API.G_EXC_ERROR;
				end if;

		   end loop;
	   END IF;



     /* IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_tl_flag := PVX_UTILITY_PVT.check_uniqueness(
         'PV_ATTRIBUTES_TL','SHORT_NAME = ''' || p_attribute_rec.SHORT_NAME
	 ||''' AND LANGUAGE = ' || userenv('LANG') );
      END IF ;

      IF l_valid_tl_flag = FND_API.g_false THEN
		  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_DUPLICATE_RECORD');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- End
	*/
END check_uk_items;

PROCEDURE check_req_items(
    p_attribute_rec               IN  attribute_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_attribute_rec.attribute_id = FND_API.g_miss_num OR p_attribute_rec.attribute_id IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','attribute_id');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.last_update_date = FND_API.g_miss_date OR p_attribute_rec.last_update_date IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','last_update_date');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.last_updated_by = FND_API.g_miss_num OR p_attribute_rec.last_updated_by IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','last_updated_by');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.creation_date = FND_API.g_miss_date OR p_attribute_rec.creation_date IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','creation_date');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.created_by = FND_API.g_miss_num OR p_attribute_rec.created_by IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','created_by');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.last_update_login = FND_API.g_miss_num OR p_attribute_rec.last_update_login IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','last_update_login');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.object_version_number = FND_API.g_miss_num OR p_attribute_rec.object_version_number IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','object_version_number');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.enabled_flag = FND_API.g_miss_char OR p_attribute_rec.enabled_flag IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','enabled_flag');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_attribute_rec.short_name = FND_API.g_miss_char OR p_attribute_rec.short_name IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','short_name');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   ELSE


      IF p_attribute_rec.attribute_id IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','attribute_id');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.last_update_date IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','last_update_date');
			 FND_MSG_PUB.add;
		 END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.last_updated_by IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','last_updated_by');
			 FND_MSG_PUB.add;
		 end if;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.creation_date IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','creation_date');
			 FND_MSG_PUB.add;
		 end if;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.created_by IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','created_by');
			 FND_MSG_PUB.add;
		 end if;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.last_update_login IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','last_update_login');
			 FND_MSG_PUB.add;
		 end if;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.object_version_number IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','object_version_number');
			 FND_MSG_PUB.add;
		 end if;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_attribute_rec.enabled_flag IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','enabled_flag');
			 FND_MSG_PUB.add;
		 end if;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


     IF p_attribute_rec.short_name IS NULL THEN
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			 FND_MESSAGE.set_token('COLUMN','short_name');
			 FND_MSG_PUB.add;
		 end if;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;



END check_req_items;

PROCEDURE check_fk_items(
    p_attribute_rec IN attribute_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_fk_items;

PROCEDURE check_lookup_items(
    p_attribute_rec IN attribute_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_lookup_items;

PROCEDURE Check_attribute_Items (
     p_attribute_rec    IN    attribute_rec_type
    ,p_validation_mode  IN    VARCHAR2
    ,x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

      --DBMS_output.put_line('Before check_uk_items');

   check_uk_items(
      p_attribute_rec => p_attribute_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

     --DBMS_output.put_line('Before check_req_items');

   check_req_items(
      p_attribute_rec => p_attribute_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

     --DBMS_output.put_line('Before check_fk_items');

   check_fk_items(
      p_attribute_rec => p_attribute_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

     --DBMS_output.put_line('Before check_lookup_items');

   check_lookup_items(
      p_attribute_rec => p_attribute_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


END Check_attribute_Items;



PROCEDURE Complete_attribute_Rec (
   p_attribute_rec IN attribute_rec_type,
   x_complete_rec OUT NOCOPY attribute_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_attributes_vl
      WHERE attribute_id = p_attribute_rec.attribute_id;
   l_attribute_rec c_complete%ROWTYPE;
BEGIN

   x_complete_rec := p_attribute_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_attribute_rec;
   CLOSE c_complete;

   -- attribute_id
   IF p_attribute_rec.attribute_id = FND_API.g_miss_num THEN
      x_complete_rec.attribute_id := l_attribute_rec.attribute_id;
   END IF;

   -- last_update_date
   IF p_attribute_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_attribute_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_attribute_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_attribute_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_attribute_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_attribute_rec.creation_date;
   END IF;

   -- created_by
   IF p_attribute_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_attribute_rec.created_by;
   END IF;

   -- last_update_login
   IF p_attribute_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_attribute_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_attribute_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_attribute_rec.object_version_number;
   END IF;

   -- security_group_id
   /*
   IF p_attribute_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_attribute_rec.security_group_id;
   END IF;
   */

   -- enabled_flag
   IF p_attribute_rec.enabled_flag = FND_API.g_miss_char THEN
      x_complete_rec.enabled_flag := l_attribute_rec.enabled_flag;
   END IF;

   -- attribute_type
   IF p_attribute_rec.attribute_type = FND_API.g_miss_char THEN
      x_complete_rec.attribute_type := l_attribute_rec.attribute_type;
   END IF;

   -- attribute_category
   IF p_attribute_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_attribute_rec.attribute_category;
   END IF;

   -- seeded_flag
   IF p_attribute_rec.seeded_flag = FND_API.g_miss_char THEN
      x_complete_rec.seeded_flag := l_attribute_rec.seeded_flag;
   END IF;

   -- lov_function_name
   IF p_attribute_rec.lov_function_name = FND_API.g_miss_char THEN
      x_complete_rec.lov_function_name := l_attribute_rec.lov_function_name;
   END IF;

   -- return_type
   IF p_attribute_rec.return_type = FND_API.g_miss_char THEN
      x_complete_rec.return_type := l_attribute_rec.return_type;
   END IF;

   -- max_value_flag
   IF p_attribute_rec.max_value_flag = FND_API.g_miss_char THEN
      x_complete_rec.max_value_flag := l_attribute_rec.max_value_flag;
   END IF;

   -- name
   IF p_attribute_rec.name = FND_API.g_miss_char THEN
      x_complete_rec.name := l_attribute_rec.name;
   END IF;

   -- description
   IF p_attribute_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_attribute_rec.description;
   END IF;

   -- short_name
   IF p_attribute_rec.short_name = FND_API.g_miss_char THEN
      x_complete_rec.short_name := l_attribute_rec.short_name;
   END IF;

-- dispaly_style
   IF p_attribute_rec.display_style = FND_API.g_miss_char THEN
      x_complete_rec.display_style := l_attribute_rec.display_style;
   END IF;

-- character_width
   IF p_attribute_rec.character_width = FND_API.g_miss_num THEN
      x_complete_rec.character_width := l_attribute_rec.character_width;
   END IF;

-- decimal_points
   IF p_attribute_rec.decimal_points = FND_API.g_miss_num THEN
      x_complete_rec.decimal_points := l_attribute_rec.decimal_points;
   END IF;

-- no_of_lines
   IF p_attribute_rec.no_of_lines = FND_API.g_miss_num THEN
      x_complete_rec.no_of_lines := l_attribute_rec.no_of_lines;
   END IF;

-- expose_to_partner_flag
   IF p_attribute_rec.expose_to_partner_flag = FND_API.g_miss_char THEN
      x_complete_rec.expose_to_partner_flag := l_attribute_rec.expose_to_partner_flag;
   END IF;

-- value_extn_return_type
   IF p_attribute_rec.value_extn_return_type = FND_API.g_miss_char THEN
      x_complete_rec.value_extn_return_type := l_attribute_rec.value_extn_return_type;
   END IF;

-- enable_matching_flag
   IF p_attribute_rec.enable_matching_flag = FND_API.g_miss_char THEN
      x_complete_rec.enable_matching_flag := l_attribute_rec.enable_matching_flag;

   END IF;

-- PErformance flag
   IF p_attribute_rec.performance_flag = FND_API.g_miss_char THEN
      x_complete_rec.performance_flag := l_attribute_rec.performance_flag;

   END IF;

-- Additive flag
   IF p_attribute_rec.additive_flag = FND_API.g_miss_char THEN
      x_complete_rec.additive_flag := l_attribute_rec.additive_flag;

   END IF;

-- sequence_number
   IF p_attribute_rec.sequence_number = FND_API.g_miss_num THEN
      x_complete_rec.sequence_number := l_attribute_rec.sequence_number;

   END IF;



   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_attribute_Rec;

PROCEDURE Validate_attribute(
     p_api_version_number        IN   NUMBER
    ,p_init_msg_list             IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level          IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_validation_mode           IN   VARCHAR2     := JTF_PLSQL_API.g_update
    ,p_attribute_rec             IN   attribute_rec_type
    ,x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                 OUT NOCOPY  NUMBER
    ,x_msg_data                  OUT NOCOPY  VARCHAR2

    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Attribute';
L_FULL_NAME                 CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_attribute_rec  PV_Attribute_PVT.attribute_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_ATTRIBUTE_PVT;
      --DBMS_output.put_line('Begin Validate_attribute');


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

       --DBMS_output.put_line('Before Check_attribute_Items');

              Check_attribute_Items(
                 p_attribute_rec        => p_attribute_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

       --DBMS_output.put_line('Before Complete_attribute_Rec');

      Complete_attribute_Rec(
         p_attribute_rec        => p_attribute_rec,
         x_complete_rec         => l_attribute_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

        --DBMS_output.put_line('Before Validate_attribute_Rec');

         Validate_attribute_Rec(
            p_api_version_number     => 1.0
           ,p_init_msg_list          => FND_API.G_FALSE
           ,x_return_status          => x_return_status
           ,x_msg_count              => x_msg_count
           ,x_msg_data               => x_msg_data
           ,p_attribute_rec          => l_attribute_rec
           ,p_validation_mode        => p_validation_mode
         );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: ' || L_FULL_NAME || 'start');
	  END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: ' || L_FULL_NAME || 'end');
	  END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN

     x_return_status := FND_API.g_ret_sts_error;
 PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Attribute_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Attribute_PVT;
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

End Validate_Attribute;


PROCEDURE Validate_attribute_rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_attribute_rec              IN    attribute_rec_type
    ,p_validation_mode           IN   VARCHAR2     := JTF_PLSQL_API.G_UPDATE
    )
IS
BEGIN

       --DBMS_output.put_line('validate_attribute_rec');

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
      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	  PVX_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
	  END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_attribute_Rec;

END PV_Attribute_PVT;

/
