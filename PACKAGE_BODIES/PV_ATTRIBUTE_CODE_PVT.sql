--------------------------------------------------------
--  DDL for Package Body PV_ATTRIBUTE_CODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTRIBUTE_CODE_PVT" as
 /* $Header: pvxvatcb.pls 120.1 2005/06/30 14:47:38 appldev ship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_Attribute_Code_PVT
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- End of Comments
 -- ===============================================================


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ATTRIBUTE_CODE_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvatcb.pls';

 G_USER_ID         NUMBER := NVL(FND_GLOBAL.USER_ID,-1);
 G_LOGIN_ID        NUMBER := NVL(FND_GLOBAL.CONC_LOGIN_ID,-1);

 -- Hint: Primary key needs to be returned.

 PROCEDURE Create_Attribute_Code(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attribute_code_rec         IN   attribute_code_rec_type  := g_miss_attribute_code_rec
    ,x_attr_code_id               OUT NOCOPY  NUMBER
    )
  IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Attribute_Code';
    l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
    l_api_version_number        CONSTANT NUMBER   := 1.0;
    l_return_status_full        VARCHAR2(1);
    l_object_version_number     NUMBER := 1;
    l_org_id                    NUMBER := FND_API.G_MISS_NUM;
    l_attr_code_id              NUMBER;
    l_dummy                     NUMBER;
    l_attribute_code_rec        attribute_code_rec_type  := p_attribute_code_rec;

    CURSOR c_id IS
       SELECT PV_ATTRIBUTE_CODES_S.NEXTVAL
       FROM dual;

    CURSOR c_id_exists (l_id IN NUMBER) IS
       SELECT 1
       FROM PV_ATTRIBUTE_CODES_B
       WHERE ATTR_CODE_ID = l_id;

 BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT CREATE_Attribute_Code_PVT;

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
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
	   end if;


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Local variable initialization

    IF p_attribute_code_rec.attr_code_id IS NULL
       OR p_attribute_code_rec.attr_code_id = FND_API.g_miss_num THEN
       LOOP
          l_dummy := NULL;
          OPEN c_id;
          FETCH c_id INTO l_attr_code_id;
          CLOSE c_id;

          OPEN c_id_exists(l_attr_code_id);
          FETCH c_id_exists INTO l_dummy;
          CLOSE c_id_exists;
          EXIT WHEN l_dummy IS NULL;
       END LOOP;
    ELSE
       l_attr_code_id := p_attribute_code_rec.attr_code_id;
    END IF;

       -- =========================================================================
       -- Validate Environment
       -- =========================================================================

       IF FND_GLOBAL.User_Id IS NULL
       THEN
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
			   FND_MSG_PUB.add;
		   end if;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
       THEN
           -- Debug message
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Validate_Attribute_Code');
		   end if;

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before Validate_attribute_Code' );

           -- Populate the default required items
           l_attribute_code_rec.attr_code_id          := l_attr_code_id;
           l_attribute_code_rec.last_update_date      := SYSDATE;
           l_attribute_code_rec.last_updated_by       := G_USER_ID;
           l_attribute_code_rec.creation_date         := SYSDATE;
           l_attribute_code_rec.created_by            := G_USER_ID;
           l_attribute_code_rec.last_update_login     := G_LOGIN_ID;
           l_attribute_code_rec.object_version_number := l_object_version_number;

           -- Invoke validation procedures
           Validate_Attribute_Code(
             p_api_version_number   => 1.0
            ,p_init_msg_list        => FND_API.G_FALSE
            ,p_validation_level     => p_validation_level
            ,p_validation_mode      => JTF_PLSQL_API.g_create
            ,p_attribute_code_rec   => l_attribute_code_rec
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data
            );

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Validate_attribute_code' );
       END IF;

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Validate' );
       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling create table handler');
	   end if;

       -- Invoke table handler(PV_ATTRIBUTE_CODE_PKG.Insert_Row)
       PV_ATTRIBUTE_CODE_PKG.Insert_Row(
           px_attr_code_id           => l_attribute_code_rec.attr_code_id,
           p_attr_code               => UPPER(l_attribute_code_rec.attr_code),
           p_last_update_date        => l_attribute_code_rec.last_update_date,
           p_last_updated_by         => l_attribute_code_rec.last_updated_by,
           p_creation_date           => l_attribute_code_rec.creation_date,
           p_created_by              => l_attribute_code_rec.created_by,
           p_last_update_login       => l_attribute_code_rec.last_update_login,
           px_object_version_number  => l_attribute_code_rec.object_version_number,
           p_attribute_id            => l_attribute_code_rec.attribute_id,
           p_enabled_flag            => l_attribute_code_rec.enabled_flag,
           --p_security_group_id  => p_attribute_code_rec.security_group_id
           p_description             => l_attribute_code_rec.description
           );

--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After' );

          x_ATTR_CODE_ID := l_attribute_code_rec.attr_code_id;

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
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - end');
	   end if;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_Attribute_Code_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_Attribute_Code_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO CREATE_Attribute_Code_PVT;
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
 End Create_Attribute_Code;


 PROCEDURE Update_Attribute_Code(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attribute_code_rec         IN   attribute_code_rec_type
    ,x_object_version_number      OUT NOCOPY  NUMBER
    )
  IS

 CURSOR c_get_attribute_code(cv_ATTR_CODE_ID NUMBER) IS
     SELECT *
     FROM  PV_ATTRIBUTE_CODES_B
     WHERE ATTR_CODE_ID = cv_ATTR_CODE_ID;

 l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Attribute_Code';
 l_full_name                CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_api_version_number       CONSTANT NUMBER   := 1.0;
 -- Local Variables
 l_object_version_number    NUMBER;
 l_ATTR_CODE_ID       NUMBER;
 l_ref_attribute_code_rec  c_get_attribute_code%ROWTYPE ;
 l_tar_attribute_code_rec  PV_ATTRIBUTE_CODE_PVT.attribute_code_rec_type := p_attribute_code_rec;
 --l_attribute_code_rec      PV_ATTRIBUTE_CODE_PVT.attribute_code_rec_type := p_attribute_code_rec;
 l_rowid  ROWID;

 l_being_used_list	    VARCHAR2(30000);
   l_delete_flag	    VARCHAR2(1):='Y';

cursor lc_check_rules (pc_attr_code_id number) is
 select  distinct seleted.attribute_value,rules.process_rule_name
   from pv_enty_select_criteria criteria,pv_selected_attr_values seleted,
        pv_process_rules_vl rules,pv_attribute_codes_vl code
   where code.attr_code_id= pc_attr_code_id and
         criteria.attribute_id= code.attribute_id and
         criteria.selection_criteria_id= seleted.selection_criteria_id and
         criteria.process_rule_id= rules.process_rule_id and
         seleted.attribute_value=code.attr_code;

cursor lc_check_programs (pc_attr_code_id number) is
	select pp.program_id, pp.program_name, ppt.partner_type
	from pv_partner_program_vl pp, pv_partner_program_type_b pt,
	pv_program_partner_types ppt, pv_attribute_codes_vl code
	where
	pp.program_type_id = ppt.program_type_id
	and pp.PROGRAM_STATUS_CODE NOT IN ('CANCEL', 'CLOSED','ARCHIVE')
	and pp.program_type_id = pt.program_type_id
	and pt.enabled_flag = 'Y'
	and ppt.partner_type = code.attr_code
	and code.attr_code_id= pc_attr_code_id
        and code.attribute_id = 3;



cursor lc_check_attr_enty_vals (pc_attr_code_id number) is
   select distinct entity
   from pv_enty_attr_values entyval, pv_attribute_codes_vl code
   where code.attr_code_id= pc_attr_code_id and
         code.attribute_id = entyval.attribute_id and
	 code.attr_code=entyval.attr_value and
	 entyval.latest_flag = 'Y' ;



  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT UPDATE_Attribute_Code_PVT;

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
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
	   end if;


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Open Cursor to Select');
	   end if;


       OPEN c_get_attribute_code( l_tar_attribute_code_rec.attr_code_id);

       FETCH c_get_attribute_code INTO l_ref_attribute_code_rec  ;

        IF ( c_get_attribute_code%NOTFOUND) THEN
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
			   FND_MESSAGE.set_token('MODE','Update');
			   FND_MESSAGE.set_token('ENTITY','Attribute_Code');
			   FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_attribute_code_rec.attr_code_id));
			   FND_MSG_PUB.add;
		   end if;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Debug Message
         IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		 PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Close Cursor');
		 end if;
        CLOSE     c_get_attribute_code;

 if(l_ref_attribute_code_rec.enabled_flag = 'Y' and p_attribute_code_rec.enabled_flag= 'N') then

     --check for seeded attribute code
   /*  if(p_attribute_code_rec.attr_code_id <10000) then
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
              FND_MESSAGE.Set_Name('PV', 'PV_ATTRCODE_NOTDISABLED_SEEDED');
              FND_MESSAGE.Set_Token('ATTRIBUTE_CODE',p_attribute_code_rec.attr_code );
	      FND_MSG_PUB.Add;
        END IF;
	RAISE FND_API.G_EXC_ERROR;
     end if;
*/

     --check for rules reference
      for x in lc_check_rules (pc_attr_code_id =>p_attribute_code_rec.attr_code_id)
      loop
        l_delete_flag := 'N' ;
	l_being_used_list := l_being_used_list || ','|| x.process_rule_name ;
      end loop;


       if(l_delete_flag = 'N') then

	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
              FND_MESSAGE.Set_Name('PV', 'PV_ATTRCODE_NOTDISABLED_RULE');
              FND_MESSAGE.Set_Token('ATTRIBUTE_CODE',p_attribute_code_rec.attr_code );
	      FND_MESSAGE.Set_Token('RULES_LIST',substr(l_being_used_list,2) );
              FND_MSG_PUB.Add;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

      end if;

      l_being_used_list := '';

      --check for programs reference  for atttibute is 3, which is partner types
      -- for bug# 3477359

      if(p_attribute_code_rec.attribute_id = 3) then
	      for x in lc_check_programs (pc_attr_code_id =>p_attribute_code_rec.attr_code_id)
	      loop
		l_delete_flag := 'N' ;
		l_being_used_list := l_being_used_list || ','|| x.program_name ;
	      end loop;


	       if(l_delete_flag = 'N') then

		   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		      THEN
		      FND_MESSAGE.Set_Name('PV', 'PV_ATTRCODE_NOTDISABLED_PROGR');
		      FND_MESSAGE.Set_Token('ATTRIBUTE_CODE',p_attribute_code_rec.attr_code );
		      FND_MESSAGE.Set_Token('PROGRAMS_LIST',substr(l_being_used_list,2) );
		      FND_MSG_PUB.Add;
		END IF;

		RAISE FND_API.G_EXC_ERROR;

	      end if;
      end if;


	 --check for entity value reference for seded attr codes for bug# 3203420
      if (p_attribute_code_rec.attr_code_id < 10000) then

	      for x in lc_check_attr_enty_vals (pc_attr_code_id =>p_attribute_code_rec.attr_code_id)
	      loop
		l_delete_flag := 'N';
		l_being_used_list := l_being_used_list || ','|| x.entity ;
	      end loop;
	       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		      FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
				  FND_MESSAGE.set_token('TEXT', 'Entity List '|| l_being_used_list );
				  FND_MSG_PUB.add;
		END IF;


	      if(l_delete_flag = 'N') then

		  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		      THEN
		      FND_MESSAGE.Set_Name('PV', 'PV_ATTRCODE_NOTDISABLED_ENTITY');
		      FND_MESSAGE.Set_Token('ATTRIBUTE_CODE',p_attribute_code_rec.attr_code );
		      FND_MESSAGE.Set_Token('ENTITY_LIST',substr(l_being_used_list,2) );
		      FND_MSG_PUB.Add;
		END IF;

		RAISE FND_API.G_EXC_ERROR;

	      end if;

      end if;

  end if;
       IF (l_tar_attribute_code_rec.object_version_number is NULL or
           l_tar_attribute_code_rec.object_version_number = FND_API.G_MISS_NUM ) Then

		   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
			   FND_MESSAGE.set_token('COLUMN',TO_CHAR(l_tar_attribute_code_rec.last_update_date));
			   FND_MSG_PUB.add;
		   end if;
           RAISE FND_API.G_EXC_ERROR;
       End if;

       -- Check Whether record has been changed by someone else
       If (l_tar_attribute_code_rec.object_version_number <> l_ref_attribute_code_rec.object_version_number) Then
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			   FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
			   FND_MESSAGE.set_token('VALUE','Attribute_Code');
			   FND_MSG_PUB.add;
		   end if;
           RAISE FND_API.G_EXC_ERROR;
       End if;
       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
       THEN
           -- Debug message
           IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Validate_Attribute_Code');
		   end if;

           -- Invoke validation procedures
           Validate_Attribute_Code(
             p_api_version_number   => 1.0
            ,p_init_msg_list        => FND_API.G_FALSE
            ,p_validation_level     => p_validation_level
            ,p_validation_mode      => JTF_PLSQL_API.g_update
            ,p_attribute_code_rec   => p_attribute_code_rec
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data
            );

       END IF;

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;


       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
       PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling update table handler');
	   end if;

       -- Invoke table handler(PV_ATTRIBUTE_CODE_PKG.Update_Row)
       PV_ATTRIBUTE_CODE_PKG.Update_Row(
           p_attr_code_id           => p_attribute_code_rec.attr_code_id,
           p_attr_code              => p_attribute_code_rec.attr_code,
           p_last_update_date       => SYSDATE,
           p_last_updated_by        => G_USER_ID,
           --p_creation_date          => SYSDATE,
           --p_created_by             => G_USER_ID,
           p_last_update_login      => G_LOGIN_ID,
           p_object_version_number  => p_attribute_code_rec.object_version_number,
           p_attribute_id           => p_attribute_code_rec.attribute_id,
           p_enabled_flag           => p_attribute_code_rec.enabled_flag,
           --p_security_group_id  => p_attribute_code_rec.security_group_id
           p_description            => p_attribute_code_rec.description
           );


          x_object_version_number := p_attribute_code_rec.object_version_number + 1;
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
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - end');
	   end if;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_Attribute_Code_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Attribute_Code_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Attribute_Code_PVT;
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
 End Update_Attribute_Code;


 PROCEDURE Delete_Attribute_Code(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attr_code_id               IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    )

  IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Attribute_Code';
 l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_api_version_number        CONSTANT NUMBER   := 1.0;
 l_object_version_number     NUMBER;
 l_attribute_id		     NUMBER;
 l_attribute_name            VARCHAR2(60);
 l_delete_flag	             VARCHAR2(1):='Y';
 l_being_used_list	    VARCHAR2(30000);
 l_attr_code	             VARCHAR2(30);
 l_meaning					VARCHAR2(80);
cursor lc_get_attr_code_details (pc_attr_code_id number) is
   select code.attr_code
   from pv_attribute_codes_vl code
   where code.attr_code_id= pc_attr_code_id ;

cursor lc_get_attr_details (pc_attr_code_id number) is
   select attr.attribute_id,attr.name
   from pv_attributes_vl attr,pv_attribute_codes_vl code
   where code.attr_code_id= pc_attr_code_id and code.attribute_id = attr.attribute_id;

cursor lc_check_attr_enty_vals (pc_attr_code_id number) is
   select distinct entity
   from pv_enty_attr_values entyval, pv_attribute_codes_vl code
   where code.attr_code_id= pc_attr_code_id and
         code.attribute_id = entyval.attribute_id and
	 code.attr_code=entyval.attr_value;


cursor lc_check_rules (pc_attr_code_id number) is
 select  distinct seleted.attribute_value,rules.process_rule_name
   from pv_enty_select_criteria criteria,pv_selected_attr_values seleted,
        pv_process_rules_vl rules,pv_attribute_codes_vl code
   where code.attr_code_id= pc_attr_code_id and
         criteria.attribute_id= code.attribute_id and
         criteria.selection_criteria_id= seleted.selection_criteria_id and
         criteria.process_rule_id= rules.process_rule_id and
         seleted.attribute_value=code.attr_code;

cursor lc_attribute_usages (pc_attr_code_id number) is
   select  distinct usage.attribute_usage_code
   from pv_attribute_usages usage, pv_attribute_codes_vl code
   where code.attr_code_id=pc_attr_code_id  and
         code.attr_code=usage.attribute_usage_code;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT DELETE_Attribute_Code_PVT;

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
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
	   end if;


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       --
       -- Api body
       --


      --getting attr code details
      for x in lc_get_attr_code_details (pc_attr_code_id =>p_attr_code_id)
      loop
	      l_attr_code := x.attr_code;

	      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
              FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
			  FND_MESSAGE.set_token('TEXT', 'Attr Code:-- '|| l_attr_code);
			  FND_MSG_PUB.add;
		  END IF;
      end loop;


      --getting attr details
      for x in lc_get_attr_details (pc_attr_code_id =>p_attr_code_id)
      loop
	      l_attribute_id := x.attribute_id;

	      l_attribute_name := x.name;

	     IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
              FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
			  FND_MESSAGE.set_token('TEXT', 'Attr:-- '|| l_attribute_id );
			  FND_MSG_PUB.add;
         END IF;
      end loop;

	 --check for seeded attribute code
     if(p_attr_code_id <10000) then
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
              FND_MESSAGE.Set_Name('PV', 'PV_ATTRCODE_NOTDELETE_SEEDED');
              FND_MESSAGE.Set_Token('ATTRIBUTE_CODE',l_attr_code );
			  FND_MSG_PUB.Add;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
     end if;

     --check attribute usage code if VAD_OF or RESELLERS if attribute_id=3 Partner Types attribute
	 --check attribute usages if attribute_id=3 Partner Types attribute

     if(l_attribute_id = 3) then

		if(l_attr_code = 'VAD' or l_attr_code = 'RESELLER') then
			l_delete_flag := 'N';
		end if;

		if(l_delete_flag = 'N') then

			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
			FND_MESSAGE.Set_Name('PV', 'PV_ATTRCODE_VADOF_RESELLERS');
			FND_MESSAGE.Set_Token('NAME',l_attribute_name );
			FND_MSG_PUB.Add;
			END IF;

			RAISE FND_API.G_EXC_ERROR;

		 end if;

		for x in lc_attribute_usages (pc_attr_code_id =>p_attr_code_id)
		loop
			l_delete_flag := 'N';

		end loop;


		if(l_delete_flag = 'N') then

			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
			FND_MESSAGE.Set_Name('PV', 'PV_ATTRCODE_REFERENCED_USAGE');
			FND_MESSAGE.Set_Token('ATTRIBUTE_CODE',l_attr_code );
			FND_MSG_PUB.Add;
			END IF;

			RAISE FND_API.G_EXC_ERROR;

		end if;
      end if; -- end if(l_attribute_id=3)


     --check for entity value reference

      for x in lc_check_attr_enty_vals (pc_attr_code_id =>p_attr_code_id)
      loop
        l_delete_flag := 'N';
	FOR y IN (select meaning from pv_lookups
		    where lookup_type = 'PV_VALID_ENTY_VALUE_TYPES'
		    and lookup_code = x.entity
		   ) LOOP
		l_meaning := y.meaning;
	END LOOP;


	l_being_used_list := l_being_used_list || ','|| l_meaning ;
	l_meaning:='';
      end loop;

      IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
              FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
			  FND_MESSAGE.set_token('TEXT', 'Entity List '|| l_being_used_list );
			  FND_MSG_PUB.add;
      END IF;


      if(l_delete_flag = 'N') then

	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
              FND_MESSAGE.Set_Name('PV', 'PV_ATTRCODE_REFERENCED_ENTITY');
              FND_MESSAGE.Set_Token('ATTRIBUTE_CODE',l_attr_code );
	      FND_MESSAGE.Set_Token('ENTITY_LIST',substr(l_being_used_list,2) );
              FND_MSG_PUB.Add;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

      end if;

     --check for rules reference
     for x in lc_check_rules (pc_attr_code_id =>p_attr_code_id)
      loop
        l_delete_flag := 'N' ;
	l_being_used_list := l_being_used_list || ','|| x.process_rule_name ;
      end loop;


       if(l_delete_flag = 'N') then

	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
              FND_MESSAGE.Set_Name('PV', 'PV_ATTR_REFERENCED_RULE');
              FND_MESSAGE.Set_Token('ATTRIBUTE_CODE',l_attr_code );
	      FND_MESSAGE.Set_Token('RULES_LIST',substr(l_being_used_list,2) );
              FND_MSG_PUB.Add;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

      end if;

      -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling delete table handler');
       END IF;


       -- Invoke table handler(PV_ATTRIBUTE_CODE_PKG.Delete_Row)
       PV_ATTRIBUTE_CODE_PKG.Delete_Row(
           p_ATTR_CODE_ID  => p_ATTR_CODE_ID);




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
       PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - end');
	   END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_Attribute_Code_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_Attribute_Code_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO DELETE_Attribute_Code_PVT;
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
 End Delete_Attribute_Code;



 -- Hint: Primary key needs to be returned.
 PROCEDURE Lock_Attribute_Code(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_ATTR_CODE_ID         IN   NUMBER
    ,p_object_version             IN   NUMBER
    )

  IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_Attribute_Code';
 l_api_version_number        CONSTANT NUMBER   := 1.0;
 L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_ATTR_CODE_ID                  NUMBER;

 CURSOR c_Attribute_Code IS
    SELECT ATTR_CODE_ID
    FROM PV_ATTRIBUTE_CODES_B
    WHERE ATTR_CODE_ID = p_ATTR_CODE_ID
    AND object_version_number = p_object_version
    FOR UPDATE NOWAIT;

 BEGIN
         -- Standard Start of API savepoint
       SAVEPOINT LOCK_Attribute_Code_PVT;

       -- Debug Message
	   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
       PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
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

   PVX_Utility_PVT.debug_message(l_full_name||': start');
   OPEN c_Attribute_Code;

   FETCH c_Attribute_Code INTO l_ATTR_CODE_ID;

   IF (c_Attribute_Code%NOTFOUND) THEN
     CLOSE c_Attribute_Code;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('PV', 'PV_API_RECORD_NOT_FOUND');
        FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;

   CLOSE c_Attribute_Code;

  -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
     p_encoded => FND_API.g_false,
     p_count   => x_msg_count,
     p_data    => x_msg_data);
   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
   PVX_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;
 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO LOCK_Attribute_Code_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO LOCK_Attribute_Code_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO LOCK_Attribute_Code_PVT;
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
 End Lock_Attribute_Code;


 PROCEDURE check_uk_items(
     p_attribute_code_rec IN  attribute_code_rec_type
    ,p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status       OUT NOCOPY VARCHAR2)
 IS
 l_valid_flag  VARCHAR2(1);

 cursor lc_get_attr_code (pc_attribute_id number) is
   select  attr_code from pv_attribute_codes_b
   where attribute_id = pc_attribute_id;



 BEGIN
       x_return_status := FND_API.g_ret_sts_success;
       IF p_validation_mode = JTF_PLSQL_API.g_create THEN
          l_valid_flag := PVX_Utility_PVT.check_uniqueness(
          'PV_ATTRIBUTE_CODES_B',
          'ATTR_CODE_ID = ''' || p_attribute_code_rec.ATTR_CODE_ID ||''''
          );
       ELSE
          l_valid_flag := PVX_Utility_PVT.check_uniqueness(
          'PV_ATTRIBUTE_CODES_B',
          'ATTR_CODE_ID = ''' || p_attribute_code_rec.ATTR_CODE_ID ||
          ''' AND ATTR_CODE_ID <> ' || p_attribute_code_rec.ATTR_CODE_ID
          );
       END IF;


	   IF l_valid_flag = FND_API.g_false THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
			  FND_MESSAGE.set_token('ID',to_char(p_attribute_code_rec.ATTR_CODE_ID) );
			  FND_MESSAGE.set_token('ENTITY','Attribute_Code');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

      --check for  uniqueness of attribute_code
	   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
		   for x in lc_get_attr_code (pc_attribute_id =>p_attribute_code_rec.attribute_id)
		   loop
				if (UPPER(p_attribute_code_rec.attr_code)=UPPER(x.attr_code)) then
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN

						FND_MESSAGE.set_name('PV', 'PV_DUPLICATE_RECORD');
						--FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
						--FND_MESSAGE.set_token('ID',to_char(p_attribute_code_rec.ATTR_CODE_ID) || ':::' || p_attribute_code_rec.ATTR_CODE);
						--FND_MESSAGE.set_token('ENTITY','Attribute_Code');
						FND_MSG_PUB.add;
					END IF;
					--x_return_status := FND_API.g_ret_sts_error;
					RAISE FND_API.G_EXC_ERROR;
				end if;

		   end loop;
	   END IF;

 END check_uk_items;

 PROCEDURE check_req_items(
     p_attribute_code_rec IN  attribute_code_rec_type
    ,p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status       OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    IF p_validation_mode = JTF_PLSQL_API.g_create THEN

            IF p_attribute_code_rec.attr_code_id = FND_API.G_MISS_NUM
            OR p_attribute_code_rec.attr_code_id IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','attr_code_id');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.attr_code = FND_API.G_MISS_CHAR
            OR p_attribute_code_rec.attr_code IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','attr_code');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.last_update_date = FND_API.G_MISS_DATE
            OR p_attribute_code_rec.last_update_date IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','last_update_date');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.last_updated_by = FND_API.G_MISS_NUM
            OR p_attribute_code_rec.last_updated_by IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','last_updated_by');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.creation_date = FND_API.G_MISS_DATE
            OR p_attribute_code_rec.creation_date IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','creation_date');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.created_by = FND_API.G_MISS_NUM
            OR p_attribute_code_rec.created_by IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','created_by');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.last_update_login = FND_API.G_MISS_NUM
            OR p_attribute_code_rec.last_update_login IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','last_update_login');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.object_version_number = FND_API.G_MISS_NUM
            OR p_attribute_code_rec.object_version_number IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','object_version_number');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.attribute_id = FND_API.G_MISS_NUM
            OR p_attribute_code_rec.attribute_id IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','attribute_id');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.enabled_flag = FND_API.G_MISS_CHAR
            OR p_attribute_code_rec.enabled_flag IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','enabled_flag');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;


            IF p_attribute_code_rec.description = FND_API.G_MISS_CHAR
            OR p_attribute_code_rec.description IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','description');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

    ELSE

            IF p_attribute_code_rec.attr_code_id IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','attr_code_id');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.attr_code IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','attr_code');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.last_update_date IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','last_update_date');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.last_updated_by IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','last_updated_by');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.creation_date IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','creation_date');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.created_by IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','created_by');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.last_update_login IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','last_update_login');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.object_version_number IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','object_version_number');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.attribute_id IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','attribute_id');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

            IF p_attribute_code_rec.enabled_flag IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','enabled_flag');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;



            IF p_attribute_code_rec.description IS NULL THEN
               IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				   FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
				   FND_MESSAGE.set_token('COLUMN','description');
				   FND_MSG_PUB.add;
			   END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

    END IF;

 END check_req_items;

 PROCEDURE check_FK_items(
     p_attribute_code_rec IN attribute_code_rec_type,
     x_return_status OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    -- Enter custom code here

 END check_FK_items;

 PROCEDURE check_Lookup_items(
     p_attribute_code_rec IN attribute_code_rec_type,
     x_return_status OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    -- Enter custom code here

 END check_Lookup_items;

 PROCEDURE Check_Attr_Code_Items (
     p_attribute_code_rec      IN   attribute_code_rec_type
    ,p_validation_mode         IN   VARCHAR2
    ,x_return_status           OUT NOCOPY  VARCHAR2
    )
 IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Check_Attr_Code_Items';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

 BEGIN

    -- Check Items Uniqueness API calls
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_uk_items' );
    check_uk_items(
       p_attribute_code_rec  => p_attribute_code_rec
      ,p_validation_mode     => p_validation_mode
      ,x_return_status       => x_return_status
      );
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

    -- Check Items Required/NOT NULL API calls
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_req_items' );
    check_req_items(
       p_attribute_code_rec  => p_attribute_code_rec
      ,p_validation_mode     => p_validation_mode
      ,x_return_status       => x_return_status
      );
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;
    -- Check Items Foreign Keys API calls
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_FK_items' );
    check_FK_items(
       p_attribute_code_rec  => p_attribute_code_rec
      ,x_return_status       => x_return_status
      );
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;
    -- Check Items Lookups
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before check_Lookup_items' );
    check_Lookup_items(
       p_attribute_code_rec => p_attribute_code_rec
      ,x_return_status      => x_return_status
      );
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

 END Check_Attr_Code_Items;

 PROCEDURE Complete_attribute_code_Rec (
    p_attribute_code_rec IN attribute_code_rec_type,
    x_complete_rec OUT NOCOPY attribute_code_rec_type)
 IS
    l_return_status  VARCHAR2(1);

    CURSOR c_complete IS
       SELECT *
       FROM pv_attribute_codes_b
       WHERE attr_code_id = p_attribute_code_rec.attr_code_id;
    l_attribute_code_rec c_complete%ROWTYPE;
 BEGIN
    x_complete_rec := p_attribute_code_rec;


    OPEN c_complete;
    FETCH c_complete INTO l_attribute_code_rec;
    CLOSE c_complete;

    -- attr_code_id
    IF p_attribute_code_rec.attr_code_id = FND_API.g_miss_num THEN
       x_complete_rec.attr_code_id := l_attribute_code_rec.attr_code_id;
    END IF;

    -- attr_code
    IF p_attribute_code_rec.attr_code = FND_API.g_miss_char THEN
       x_complete_rec.attr_code := l_attribute_code_rec.attr_code;
    END IF;

    -- last_update_date
    IF p_attribute_code_rec.last_update_date = FND_API.g_miss_date THEN
       x_complete_rec.last_update_date := l_attribute_code_rec.last_update_date;
    END IF;

    -- last_updated_by
    IF p_attribute_code_rec.last_updated_by = FND_API.g_miss_num THEN
       x_complete_rec.last_updated_by := l_attribute_code_rec.last_updated_by;
    END IF;

    -- creation_date
    IF p_attribute_code_rec.creation_date = FND_API.g_miss_date THEN
       x_complete_rec.creation_date := l_attribute_code_rec.creation_date;
    END IF;

    -- created_by
    IF p_attribute_code_rec.created_by = FND_API.g_miss_num THEN
       x_complete_rec.created_by := l_attribute_code_rec.created_by;
    END IF;

    -- last_update_login
    IF p_attribute_code_rec.last_update_login = FND_API.g_miss_num THEN
       x_complete_rec.last_update_login := l_attribute_code_rec.last_update_login;
    END IF;

    -- object_version_number
    IF p_attribute_code_rec.object_version_number = FND_API.g_miss_num THEN
       x_complete_rec.object_version_number := l_attribute_code_rec.object_version_number;
    END IF;

    -- attribute_id
    IF p_attribute_code_rec.attribute_id = FND_API.g_miss_num THEN
       x_complete_rec.attribute_id := l_attribute_code_rec.attribute_id;
    END IF;

    -- enabled_flag
    IF p_attribute_code_rec.enabled_flag = FND_API.g_miss_char THEN
       x_complete_rec.enabled_flag := l_attribute_code_rec.enabled_flag;
    END IF;



    -- security_group_id
    --IF p_attribute_code_rec.security_group_id = FND_API.g_miss_num THEN
    --   x_complete_rec.security_group_id := l_attribute_code_rec.security_group_id;
    --END IF;
    -- Note: Developers need to modify the procedure
    -- to handle any business specific requirements.
 END Complete_attribute_code_Rec;





 PROCEDURE Validate_Attribute_Code(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.G_UPDATE
    ,p_attribute_code_rec         IN   attribute_code_rec_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    )
  IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_Attribute_Code';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_api_version_number        CONSTANT NUMBER   := 1.0;
 l_object_version_number     NUMBER;
 l_attribute_code_rec  PV_Attribute_Code_PVT.attribute_code_rec_type;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT Validate_Attribute_Code;

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
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : Before Check_Attr_Code_Items' );
               Check_Attr_Code_Items(
                  p_attribute_code_rec  => p_attribute_code_rec
                 ,p_validation_mode     => p_validation_mode
                 ,x_return_status       => x_return_status
                 );
--DBMS_OUTPUT.PUT_LINE(l_full_name||' : After Check_Attr_Code_Items' );
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
       END IF;

       Complete_attribute_code_rec(
          p_attribute_code_rec  => p_attribute_code_rec
         ,x_complete_rec        => l_attribute_code_rec
       );

       IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
          Validate_attr_code_rec(
            p_api_version_number  => 1.0
           ,p_init_msg_list       => FND_API.G_FALSE
           ,x_return_status       => x_return_status
           ,x_msg_count           => x_msg_count
           ,x_msg_data            => x_msg_data
           ,p_attribute_code_rec  => l_attribute_code_rec
           ,p_validation_mode     => p_validation_mode
           );

               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
       END IF;


       -- Debug Message

	   IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
	   END IF;
       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;


       -- Debug Message
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	   PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - end');
	   END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Validate_Attribute_Code;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Validate_Attribute_Code;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO Validate_Attribute_Code;
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
 End Validate_Attribute_Code;


 PROCEDURE Validate_Attr_Code_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_attribute_code_rec         IN   attribute_code_rec_type
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
       IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	   PVX_Utility_PVT.debug_message('Private API: Validate_dm_model_rec');
	   END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 END VALIDATE_ATTR_CODE_REC;

 END PV_ATTRIBUTE_CODE_PVT;


/
