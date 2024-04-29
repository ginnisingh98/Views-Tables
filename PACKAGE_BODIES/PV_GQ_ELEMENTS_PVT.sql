--------------------------------------------------------
--  DDL for Package Body PV_GQ_ELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GQ_ELEMENTS_PVT" as
/* $Header: pvxvgqeb.pls 120.3 2005/08/26 10:20:33 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Gq_Elements_PVT
-- Purpose
--
-- History
--        15-DEC-2002    Karen.Tsao     Created
--        10-DEC-2002    Karen.Tsao     1. Use <> instead of !=
--                                      2. Added line "WHENEVER OSERROR EXIT FAILURE ROLLBACK;"
--        20-DEC-2002    Karen.Tsao     1. Change API_VERSION_MISSING to PV_API_VERSION_MISSING
--                                      2. Change API_RECORD_CHANGED to PV_API_RECORD_CHANGED, INFO to VALUE
--        20-JAN-2003    Karen.Tsao     Added validation to make sure that a question is marked as mandatory only
--                                      if profile attribute exists.
--        24-JUN-2003    Karen.Tsao     Fixed for bug 3010255. Added check_uniqueness() for profile attribute in
--                                      check_Qsnr_Element_Uk_Items method.
--        16-JAN-2004    Karen.Tsao     Fixed for bug #3380368. Modified Logic in check_Qsnr_Element_Uk_Items().
--        16-JAN-2004    Karen.Tsao     Modified code in Check_Qsnr_Element_Items() for performance reason.
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Gq_Elements_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvgqeb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Qsnr_Element_Items (
   p_qsnr_element_rec IN  qsnr_element_rec_type ,
   x_qsnr_element_rec OUT NOCOPY qsnr_element_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Gq_Elements
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_qsnr_element_rec            IN   qsnr_element_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Gq_Elements(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qsnr_element_rec              IN   qsnr_element_rec_type  := g_miss_qsnr_element_rec,
    x_qsnr_element_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Gq_Elements';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_qsnr_element_id              NUMBER;
   l_dummy                     NUMBER;
   l_qsnr_element_rec                  qsnr_element_rec_type  := p_qsnr_element_rec;

   CURSOR c_id IS
      SELECT pv_ge_qsnr_elements_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_GE_QSNR_ELEMENTS_B
      WHERE qsnr_element_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_gq_elements_pvt;

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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_qsnr_element_rec.qsnr_element_id IS NULL OR p_qsnr_element_rec.qsnr_element_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_qsnr_element_id;
         CLOSE c_id;

         OPEN c_id_exists(l_qsnr_element_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_qsnr_element_id := p_qsnr_element_rec.qsnr_element_id;
   END IF;
   l_qsnr_element_rec.qsnr_element_id := l_qsnr_element_id;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         PVX_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Gq_Elements');
          END IF;

           -- Populate the default required items
           l_qsnr_element_rec.last_update_date      := SYSDATE;
           l_qsnr_element_rec.last_updated_by       := FND_GLOBAL.user_id;
           l_qsnr_element_rec.creation_date         := SYSDATE;
           l_qsnr_element_rec.created_by            := FND_GLOBAL.user_id;
           l_qsnr_element_rec.last_update_login     := FND_GLOBAL.conc_login_id;
           l_qsnr_element_rec.object_version_number := l_object_version_number;

          -- Invoke validation procedures
          Validate_gq_elements(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_qsnr_element_rec  =>  l_qsnr_element_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(Pv_Gq_Elements_Pkg.Insert_Row)

      Pv_Gq_Elements_Pkg.Insert_Row(
          px_qsnr_element_id         => l_qsnr_element_rec.qsnr_element_id,
          px_object_version_number   => l_qsnr_element_rec.object_version_number,
          p_arc_used_by_entity_code  => l_qsnr_element_rec.arc_used_by_entity_code,
          p_used_by_entity_id        => l_qsnr_element_rec.used_by_entity_id,
          p_qsnr_elmt_seq_num        => l_qsnr_element_rec.qsnr_elmt_seq_num,
          p_qsnr_elmt_type           => l_qsnr_element_rec.qsnr_elmt_type,
          p_entity_attr_id           => l_qsnr_element_rec.entity_attr_id,
          p_qsnr_elmt_page_num       => l_qsnr_element_rec.qsnr_elmt_page_num,
          p_is_required_flag         => l_qsnr_element_rec.is_required_flag,
          p_created_by               => FND_GLOBAL.USER_ID,
          p_creation_date            => SYSDATE,
          p_last_updated_by          => FND_GLOBAL.USER_ID,
          p_last_update_date         => SYSDATE,
          p_last_update_login        => FND_GLOBAL.conc_login_id,
          p_elmt_content             => l_qsnr_element_rec.elmt_content
      );

      x_qsnr_element_id := l_qsnr_element_id;
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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Gq_Elements_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Gq_Elements_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Gq_Elements_PVT;
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
End Create_Gq_Elements;






/*********************
 *
 *
 * Copy_Row
 *
 *
 *********************/
PROCEDURE Copy_Row
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
)
IS
   CURSOR c_get_qsnr_element_rec (cv_program_id IN NUMBER)  IS
       SELECT  qsnr_elmt_seq_num, qsnr_elmt_type, entity_attr_id, qsnr_elmt_page_num, is_required_flag
       FROM    pv_ge_qsnr_elements_b
       WHERE   arc_used_by_entity_code = 'PRGM' AND used_by_entity_id = cv_program_id
       order by qsnr_element_id;

   CURSOR c_get_qsnr_element_tl_rec (cv_program_id IN NUMBER)  IS
      SELECT  tl.qsnr_element_id, elmt_content, source_lang, language
      FROM    pv_ge_qsnr_elements_b b, pv_ge_qsnr_elements_tl tl
      WHERE   b.qsnr_element_id = tl.qsnr_element_id
	  AND     b.arc_used_by_entity_code = 'PRGM'
	  AND 	  b.used_by_entity_id = cv_program_id
	  order by tl.qsnr_element_id;

   CURSOR c_id IS
      SELECT pv_ge_qsnr_elements_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_GE_QSNR_ELEMENTS_B
      WHERE qsnr_element_id = l_id;

   CURSOR c_get_additional_tl_info (cv_program_id IN NUMBER)  IS
      SELECT  QSNR_TITLE, QSNR_HEADER, QSNR_FOOTER, language
      FROM    pv_partner_program_tl tl
      WHERE   program_id = cv_program_id;

   l_qsnr_element_id          NUMBER;
   l_object_version_number    NUMBER;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'Copy_Row';
   L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;
   l_dummy 					  NUMBER;
   elmt_count				  NUMBER;

   type numArray is table of number index by binary_integer;
   type varcharArray is table of VARCHAR2(240) index by binary_integer;

   qsnr_element_id_array numArray;
   old_qsnr_element_id_array numArray;
   new_qsnr_element_id_array numArray;
   qsnr_elmt_seq_num_array numArray;
   qsnr_elmt_type_array varcharArray;
   entity_attr_id_array numArray;
   qsnr_elmt_page_num_array numArray;
   is_required_flag_array varcharArray;
   elmt_content_array varcharArray;
   source_lang_array varcharArray;
   language_array varcharArray;


   L_QSNR_TTL_ALL_PAGE_DSP_FLAG varchar2(1);
   L_QSNR_HDR_ALL_PAGE_DSP_FLAG varchar2(1);
   L_QSNR_FTR_ALL_PAGE_DSP_FLAG varchar2(1);
   QSNR_TITLE_ARRAY varcharArray;
   QSNR_HEADER_ARRAY varcharArray;
   QSNR_FOOTER_ARRAY varcharArray;
   PRGM_SOURCE_LANG_ARRAY varcharArray;
   PRGM_LANGUAGE_ARRAY varcharArray;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Row;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF (PV_DEBUG_HIGH_ON) THEN
     PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' : before open cursor');
   END IF;

   OPEN c_get_qsnr_element_rec (p_src_object_id);
   LOOP
   IF (PV_DEBUG_HIGH_ON) THEN
	PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' : inside fetching qsnr b table');
   END IF;
   FETCH c_get_qsnr_element_rec  bulk collect into
    qsnr_elmt_seq_num_array, qsnr_elmt_type_array, entity_attr_id_array,
   qsnr_elmt_page_num_array, is_required_flag_array LIMIT 100;

   IF (PV_DEBUG_HIGH_ON) THEN
    PVX_UTILITY_PVT.debug_message(l_api_name || 'qsnr_elmt_seq_num_array.count =' || to_char(qsnr_elmt_seq_num_array.count));
   END IF;

	 for i in 1..qsnr_elmt_seq_num_array.count  LOOP

         l_dummy := NULL;
         OPEN c_id;
		 LOOP
         	 --FETCH c_id INTO l_checklist_item_id; anubhav changed to
	 	 		 FETCH c_id INTO qsnr_element_id_array(i);
		 		 OPEN c_id_exists(qsnr_element_id_array(i));
		 	  	 	  FETCH c_id_exists INTO l_dummy;
		 		 CLOSE c_id_exists;
		 		 EXIT WHEN l_dummy IS NULL;
		 END LOOP;
         CLOSE c_id;
	 IF (PV_DEBUG_HIGH_ON) THEN
		 PVX_UTILITY_PVT.debug_message(l_api_name || 'qsnr_element_id_array(i) =' || to_char(qsnr_element_id_array(i)));
	 END IF;

      END LOOP;



      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' : insert into b table');

      forall i in 1..qsnr_element_id_array.count
      INSERT INTO pv_ge_qsnr_elements_b(
           qsnr_element_id,
           object_version_number,
           arc_used_by_entity_code,
           used_by_entity_id,
           qsnr_elmt_seq_num,
           qsnr_elmt_type,
           entity_attr_id,
           qsnr_elmt_page_num,
           is_required_flag,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
	   )
	   VALUES
	   (
           qsnr_element_id_array(i),
           1,
           'PRGM',
           p_tar_object_id,
           qsnr_elmt_seq_num_array(i),
           qsnr_elmt_type_array(i),
           entity_attr_id_array(i),
           qsnr_elmt_page_num_array(i),
           is_required_flag_array(i),
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.CONC_LOGIN_ID
	   );


   	   exit when c_get_qsnr_element_rec%notfound;
     END LOOP;
     Close c_get_qsnr_element_rec;


     open c_get_qsnr_element_tl_rec(p_src_object_id);
	  LOOP
      Fetch c_get_qsnr_element_tl_rec bulk collect into
	  old_qsnr_element_id_array, elmt_content_array, source_lang_array, language_array limit 100;

	  elmt_count := 1;
	  for k in 1..old_qsnr_element_id_array.count loop
	  	  if ((k <> 1) and (old_qsnr_element_id_array(k) <> old_qsnr_element_id_array(k-1))) then
	      	 elmt_count := elmt_count + 1;
	  	  end if;
		  IF (PV_DEBUG_HIGH_ON) THEN
			PVX_UTILITY_PVT.debug_message(l_api_name || 'k = ' || to_char(k));
			PVX_UTILITY_PVT.debug_message(l_api_name || 'elmt_count = ' || to_char(elmt_count));
		  END IF;
	  	  new_qsnr_element_id_array(k) := qsnr_element_id_array(elmt_count);

	  end loop;

      Forall j in 1..old_qsnr_element_id_array.count
      INSERT INTO pv_ge_qsnr_elements_tl(
           qsnr_element_id ,
           language ,
           last_update_date ,
           last_updated_by ,
           creation_date ,
           created_by ,
           last_update_login ,
           source_lang ,
           elmt_content
      )
      values
      (
           new_qsnr_element_id_array(j),
           language_array(j),
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           FND_GLOBAL.CONC_LOGIN_ID,
           source_lang_array(j),
           elmt_content_array(j)
     );

	 exit when c_get_qsnr_element_tl_rec%notfound;
	 END LOOP;
     close c_get_qsnr_element_tl_rec;

   IF (PV_DEBUG_HIGH_ON) THEN
   PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' : out of qsnr loop');
   END IF;


   OPEN c_get_additional_tl_info (p_src_object_id);
   LOOP
   IF (PV_DEBUG_HIGH_ON) THEN
   PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' : inside get addl - tl loop');
   END IF;
   FETCH c_get_additional_tl_info bulk collect into
   QSNR_TITLE_ARRAY, QSNR_HEADER_ARRAY, QSNR_FOOTER_ARRAY, PRGM_LANGUAGE_ARRAY LIMIT 100;
   Forall i in 1..QSNR_TITLE_ARRAY.count
	update pv_partner_program_tl
	set
        QSNR_TITLE = QSNR_TITLE_ARRAY(i),
        QSNR_HEADER = QSNR_HEADER_ARRAY(i),
        QSNR_FOOTER = QSNR_FOOTER_ARRAY(i),
	LAST_UPDATED_BY = FND_GLOBAL.user_id,
	LAST_UPDATE_DATE = sysdate,
	LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
	where program_id = p_tar_object_id
	and   LANGUAGE = PRGM_LANGUAGE_ARRAY(i);

   exit when c_get_additional_tl_info%notfound;
   end LOOP;
   CLOSE c_get_additional_tl_info;


   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Copy_Row;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Copy_Row;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Copy_Row;
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

END Copy_Row;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Gq_Elements
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_qsnr_element_rec            IN   qsnr_element_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Gq_Elements(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qsnr_element_rec               IN    qsnr_element_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS


CURSOR c_get_gq_elements(qsnr_element_id NUMBER) IS
    SELECT *
    FROM  PV_GE_QSNR_ELEMENTS_B
    WHERE  qsnr_element_id = p_qsnr_element_rec.qsnr_element_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Gq_Elements';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
--l_object_version_number     NUMBER;
l_object_version_number     NUMBER  := p_qsnr_element_rec.object_version_number;
l_qsnr_element_id    NUMBER;
l_ref_qsnr_element_rec  c_get_Gq_Elements%ROWTYPE ;
l_tar_qsnr_element_rec  qsnr_element_rec_type := p_qsnr_element_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_gq_elements_pvt;

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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_get_Gq_Elements( l_tar_qsnr_element_rec.qsnr_element_id);

      FETCH c_get_Gq_Elements INTO l_ref_qsnr_element_rec  ;

       If ( c_get_Gq_Elements%NOTFOUND) THEN
  PVX_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Gq_Elements') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Gq_Elements;


      If (l_tar_qsnr_element_rec.object_version_number is NULL or
          l_tar_qsnr_element_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_VERSION_MISSING',
                                        p_token_name   => 'COLUMN',
                                        p_token_value  => 'Object_Version_Number') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('tar: object_version_number = '|| l_tar_qsnr_element_rec.object_version_number);
      END IF;
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('ref: object_version_number = '|| l_ref_qsnr_element_rec.object_version_number);
      END IF;

      If (l_tar_qsnr_element_rec.object_version_number <> l_ref_qsnr_element_rec.object_version_number) Then
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RECORD_CHANGED',
                                       p_token_name   => 'VALUE',
                                       p_token_value  => 'Gq_Elements') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Gq_Elements');
          END IF;

          -- Invoke validation procedures
          Validate_gq_elements(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_qsnr_element_rec  =>  p_qsnr_element_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('p_qsnr_element_rec.qsnr_element_id = ' || p_qsnr_element_rec.qsnr_element_id);
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('p_qsnr_element_rec.qsnr_elmt_seq_num = ' || p_qsnr_element_rec.qsnr_elmt_seq_num);
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('p_qsnr_element_rec.elmt_content = ' || p_qsnr_element_rec.elmt_content);
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('p_qsnr_element_rec.entity_attr_id = ' || p_qsnr_element_rec.entity_attr_id);
         IF (p_qsnr_element_rec.entity_attr_id = FND_API.G_MISS_NUM) THEN
            PVX_UTILITY_PVT.debug_message('p_qsnr_element_rec.entity_attr_id = FND_API.G_MISS_NUM');
         ELSIF (p_qsnr_element_rec.entity_attr_id is NULL) THEN
            PVX_UTILITY_PVT.debug_message('p_qsnr_element_rec.entity_attr_id is NULL');
         END IF;
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('p_qsnr_element_rec.is_required_flag = ' || p_qsnr_element_rec.is_required_flag);
      END IF;


      IF ((p_qsnr_element_rec.entity_attr_id is NULL or p_qsnr_element_rec.entity_attr_id = FND_API.G_MISS_NUM)
          and p_qsnr_element_rec.is_required_flag = 'Y') THEN
        PVX_Utility_PVT.Error_Message(p_message_name => 'PV_MANDATORY_NO_ATTR');
        raise FND_API.G_EXC_ERROR;
      End if;

      -- Invoke table handler(Pv_Gq_Elements_Pkg.Update_Row)
      Pv_Gq_Elements_Pkg.Update_Row(
          p_qsnr_element_id         => p_qsnr_element_rec.qsnr_element_id,
          px_object_version_number  => l_object_version_number,
          p_arc_used_by_entity_code => p_qsnr_element_rec.arc_used_by_entity_code,
          p_used_by_entity_id       => p_qsnr_element_rec.used_by_entity_id,
          p_qsnr_elmt_seq_num       => p_qsnr_element_rec.qsnr_elmt_seq_num,
          p_qsnr_elmt_type          => p_qsnr_element_rec.qsnr_elmt_type,
          p_entity_attr_id          => p_qsnr_element_rec.entity_attr_id,
          p_qsnr_elmt_page_num      => p_qsnr_element_rec.qsnr_elmt_page_num,
          p_is_required_flag        => p_qsnr_element_rec.is_required_flag,
          p_last_updated_by         => FND_GLOBAL.USER_ID,
          p_last_update_date        => SYSDATE,
          p_last_update_login       => FND_GLOBAL.conc_login_id,
          p_elmt_content            => p_qsnr_element_rec.elmt_content
);
   x_object_version_number := l_object_version_number;
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Gq_Elements_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Gq_Elements_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Gq_Elements_PVT;
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
End Update_Gq_Elements;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Gq_Elements
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_qsnr_element_id                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Gq_Elements(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_qsnr_element_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS

CURSOR c_get_elmt_greater_than (cv_qsnr_element_id NUMBER) IS
   select gq.qsnr_element_id, gq.qsnr_elmt_seq_num, gq.qsnr_elmt_page_num, gq.object_version_number
   from pv_ge_qsnr_elements_vl gq,
        (select arc_used_by_entity_code, used_by_entity_id, qsnr_elmt_seq_num
         from pv_ge_qsnr_elements_vl
         where qsnr_element_id = cv_qsnr_element_id) tmp
   where gq.arc_used_by_entity_code = tmp.arc_used_by_entity_code
   and   gq.used_by_entity_id = tmp.used_by_entity_id
   and   gq.qsnr_elmt_seq_num > tmp.qsnr_elmt_seq_num;

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Gq_Elements';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_get_elmt_greater_than     c_get_elmt_greater_than%ROWTYPE;
l_qsnr_element_rec          qsnr_element_rec_type := g_miss_qsnr_element_rec;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_gq_elements_pvt;

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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Update the qsnr_elmt_page_num field of all records which have
      -- larger qsnr_element_id than the deleted one
      FOR l_get_elmt_greater_than IN c_get_elmt_greater_than (p_qsnr_element_id)
      LOOP
         l_qsnr_element_rec.qsnr_element_id := l_get_elmt_greater_than.qsnr_element_id;
         l_qsnr_element_rec.qsnr_elmt_seq_num := l_get_elmt_greater_than.qsnr_elmt_seq_num - 1;
         l_qsnr_element_rec.object_version_number := l_get_elmt_greater_than.object_version_number;
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('qsnr_element_id = ' || l_qsnr_element_rec.qsnr_element_id);
         END IF;
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('qsnr_elmt_page_num = ' || l_qsnr_element_rec.qsnr_elmt_page_num);
         END IF;
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('object_version_number = ' || l_qsnr_element_rec.object_version_number);
         END IF;

         Update_Gq_Elements ( p_api_version_number         => p_api_version_number
                             ,p_init_msg_list              => p_init_msg_list
                             ,p_commit                     => p_commit
                             ,p_validation_level           => p_validation_level
                             ,x_return_status              => x_return_status
                             ,x_msg_count                  => x_msg_count
                             ,x_msg_data                   => x_msg_data
                             ,p_qsnr_element_rec           => l_qsnr_element_rec
                             ,x_object_version_number      => l_object_version_number
                            );

      END LOOP;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(Pv_Gq_Elements_Pkg.Delete_Row)
      Pv_Gq_Elements_Pkg.Delete_Row(
          p_qsnr_element_id  => p_qsnr_element_id,
          p_object_version_number => p_object_version_number     );

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Gq_Elements_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Gq_Elements_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Gq_Elements_PVT;
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
End Delete_Gq_Elements;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Gq_PB_Elements
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_qsnr_element_id         IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Gq_PB_Elements(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_qsnr_element_id            IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

IS

CURSOR c_get_elmt_greater_than (cv_qsnr_element_id NUMBER) IS
   select gq.qsnr_element_id, gq.qsnr_elmt_seq_num, gq.qsnr_elmt_page_num, gq.object_version_number
   from pv_ge_qsnr_elements_vl gq,
        (select arc_used_by_entity_code, used_by_entity_id, qsnr_elmt_seq_num
         from pv_ge_qsnr_elements_vl
         where qsnr_element_id = cv_qsnr_element_id) tmp
   where gq.arc_used_by_entity_code = tmp.arc_used_by_entity_code
   and   gq.used_by_entity_id = tmp.used_by_entity_id
   and   gq.qsnr_elmt_seq_num > tmp.qsnr_elmt_seq_num;

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Gq_PB_Elements';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_get_elmt_greater_than     c_get_elmt_greater_than%ROWTYPE;
l_qsnr_element_rec          qsnr_element_rec_type := g_miss_qsnr_element_rec;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Gq_PB_Elements_pvt;

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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ...' || l_api_name || ' start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'p_qsnr_element_id = ' || p_qsnr_element_id);
      END IF;
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'p_object_version_number = ' || p_object_version_number);
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_UTILITY_PVT.debug_message( 'Private API: Updating qsnr_elmt_seq/page_num field');

      END IF;

      -- Update the qsnr_elmt_page_num field of all records which have
      -- larger qsnr_element_id than the deleted one
      FOR l_get_elmt_greater_than IN c_get_elmt_greater_than (p_qsnr_element_id)
      LOOP
         l_qsnr_element_rec.qsnr_element_id := l_get_elmt_greater_than.qsnr_element_id;
         l_qsnr_element_rec.qsnr_elmt_seq_num := l_get_elmt_greater_than.qsnr_elmt_seq_num - 1;
         l_qsnr_element_rec.qsnr_elmt_page_num := l_get_elmt_greater_than.qsnr_elmt_page_num - 1;
         l_qsnr_element_rec.object_version_number := l_get_elmt_greater_than.object_version_number;
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('qsnr_element_id = ' || l_qsnr_element_rec.qsnr_element_id);
         END IF;
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('qsnr_elmt_page_num = ' || l_qsnr_element_rec.qsnr_elmt_page_num);
         END IF;
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('object_version_number = ' || l_qsnr_element_rec.object_version_number);
         END IF;

         Update_Gq_Elements ( p_api_version_number         => p_api_version_number
                             ,p_init_msg_list              => p_init_msg_list
                             ,p_commit                     => p_commit
                             ,p_validation_level           => p_validation_level
                             ,x_return_status              => x_return_status
                             ,x_msg_count                  => x_msg_count
                             ,x_msg_data                   => x_msg_data
                             ,p_qsnr_element_rec           => l_qsnr_element_rec
                             ,x_object_version_number      => l_object_version_number
                            );

      END LOOP;

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler...');

      END IF;
      -- Invoke table handler(Pv_Gq_Elements_Pkg.Delete_Row)
      Pv_Gq_Elements_Pkg.Delete_Row(
          p_qsnr_element_id  => p_qsnr_element_id,
          p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Gq_PB_Elements_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Gq_PB_Elements_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Gq_PB_Elements_PVT;
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
End Delete_Gq_PB_Elements;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Gq_Elements
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_qsnr_element_rec            IN   qsnr_element_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Gq_Elements(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qsnr_element_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Gq_Elements';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_qsnr_element_id                  NUMBER;

BEGIN

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
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
Pv_Gq_Elements_Pkg.Lock_Row(l_qsnr_element_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (PV_DEBUG_HIGH_ON) THEN

  PVX_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Gq_Elements_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Gq_Elements_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Gq_Elements_PVT;
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
End Lock_Gq_Elements;




PROCEDURE check_Qsnr_Element_Uk_Items(
    p_qsnr_element_rec               IN   qsnr_element_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := PVX_Utility_PVT.check_uniqueness(
         'pv_ge_qsnr_elements_b',
         'qsnr_element_id = ''' || p_qsnr_element_rec.qsnr_element_id ||''''
         );

         IF l_valid_flag = FND_API.g_false THEN
            PVX_Utility_PVT.Error_Message(p_message_name => 'PV_qsnr_element_id_DUPLICATE');
            x_return_status := FND_API.g_ret_sts_error;
         END IF;
      END IF;

      -- Fixed for bug #3380368
      IF p_qsnr_element_rec.qsnr_elmt_type = 'QUESTION' and
         p_qsnr_element_rec.entity_attr_id is not null THEN
         IF p_validation_mode = JTF_PLSQL_API.g_create THEN
            l_valid_flag := PVX_Utility_PVT.check_uniqueness(
            'pv_ge_qsnr_elements_b',
            'used_by_entity_id = ''' || p_qsnr_element_rec.used_by_entity_id ||''' AND entity_attr_id = ''' || p_qsnr_element_rec.entity_attr_id || '''');

            IF l_valid_flag = FND_API.g_false THEN
               PVX_Utility_PVT.Error_Message(p_message_name => 'PV_QSNR_PROFILE_ATTR_DUPLICATE');
               x_return_status := FND_API.g_ret_sts_error;
            END IF;
        ELSIF p_validation_mode = JTF_PLSQL_API.g_update THEN
            l_valid_flag := PVX_Utility_PVT.check_uniqueness(
            'pv_ge_qsnr_elements_b',
            'used_by_entity_id = ''' || p_qsnr_element_rec.used_by_entity_id ||''' AND entity_attr_id = ''' || p_qsnr_element_rec.entity_attr_id || ''' AND QSNR_ELEMENT_ID <> ''' || p_qsnr_element_rec.QSNR_ELEMENT_ID || '''');

            IF l_valid_flag = FND_API.g_false THEN
               PVX_Utility_PVT.Error_Message(p_message_name => 'PV_QSNR_PROFILE_ATTR_DUPLICATE');
               x_return_status := FND_API.g_ret_sts_error;
           END IF;
        END IF;
      END IF;

END check_Qsnr_Element_Uk_Items;



PROCEDURE check_Qsnr_Element_Req_Items(
    p_qsnr_element_rec               IN  qsnr_element_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_qsnr_element_rec.qsnr_element_id = FND_API.G_MISS_NUM OR p_qsnr_element_rec.qsnr_element_id IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'QSNR_ELEMENT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.object_version_number = FND_API.G_MISS_NUM OR p_qsnr_element_rec.object_version_number IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.arc_used_by_entity_code = FND_API.g_miss_char OR p_qsnr_element_rec.arc_used_by_entity_code IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ARC_USED_BY_ENTITY_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.used_by_entity_id = FND_API.G_MISS_NUM OR p_qsnr_element_rec.used_by_entity_id IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'USED_BY_ENTITY_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.qsnr_elmt_seq_num = FND_API.G_MISS_NUM OR p_qsnr_element_rec.qsnr_elmt_seq_num IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'QSNR_ELMT_SEQ_NUM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.qsnr_elmt_type = FND_API.g_miss_char OR p_qsnr_element_rec.qsnr_elmt_type IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'QSNR_ELMT_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.qsnr_elmt_page_num = FND_API.G_MISS_NUM OR p_qsnr_element_rec.qsnr_elmt_page_num IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'QSNR_ELMT_PAGE_NUM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.is_required_flag = FND_API.g_miss_char OR p_qsnr_element_rec.is_required_flag IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'IS_REQUIRED_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.created_by = FND_API.G_MISS_NUM OR p_qsnr_element_rec.created_by IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CREATED_BY' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.creation_date = FND_API.G_MISS_DATE OR p_qsnr_element_rec.creation_date IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CREATION_DATE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.last_updated_by = FND_API.G_MISS_NUM OR p_qsnr_element_rec.last_updated_by IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATED_BY' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.last_update_date = FND_API.G_MISS_DATE OR p_qsnr_element_rec.last_update_date IS NULL THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATE_DATE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_qsnr_element_rec.qsnr_element_id = FND_API.G_MISS_NUM THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'QSNR_ELEMENT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.object_version_number = FND_API.G_MISS_NUM THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      /*
      IF p_qsnr_element_rec.arc_used_by_entity_code = FND_API.g_miss_char THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ARC_USED_BY_ENTITY_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.used_by_entity_id = FND_API.G_MISS_NUM THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'USED_BY_ENTITY_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.qsnr_elmt_seq_num = FND_API.G_MISS_NUM THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'QSNR_ELMT_SEQ_NUM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.qsnr_elmt_type = FND_API.g_miss_char THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'QSNR_ELMT_TYPE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.qsnr_elmt_page_num = FND_API.G_MISS_NUM THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'QSNR_ELMT_PAGE_NUM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.is_required_flag = FND_API.g_miss_char THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'IS_REQUIRED_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.created_by = FND_API.G_MISS_NUM THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CREATED_BY' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.creation_date = FND_API.G_MISS_DATE THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CREATION_DATE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.last_updated_by = FND_API.G_MISS_NUM THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATED_BY' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_qsnr_element_rec.last_update_date = FND_API.G_MISS_DATE THEN
               PVX_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATE_DATE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
      */
   END IF;

END check_Qsnr_Element_Req_Items;



PROCEDURE check_Qsnr_Element_Fk_Items(
    p_qsnr_element_rec IN qsnr_element_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Qsnr_Element_Fk_Items;



PROCEDURE check_Qs_Elemnt_Lookup_Items(
    p_qsnr_element_rec IN qsnr_element_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

     ----------------------- PV_QUESTIONNAIRE_ENTITY_CODE LOOKUP  ------------------------
   IF p_qsnr_element_rec.arc_used_by_entity_code <> FND_API.g_miss_char  THEN

      IF PVX_Utility_PVT.check_lookup_exists(
            'PV_LOOKUPS',                      -- Look up Table Name
            'PV_QUESTIONNAIRE_ENTITY_CODE',    -- Lookup Type
            p_qsnr_element_rec.arc_used_by_entity_code       -- Lookup Code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_ENTITY_CODE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

      END IF;
   END IF;
   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Check_Lookup_Items : After program_level_code lookup check. x_return_status = '||x_return_status);
   END IF;

END check_Qs_Elemnt_Lookup_Items;



PROCEDURE Check_Qsnr_Element_Items (
    P_qsnr_element_rec     IN    qsnr_element_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   IF (PV_DEBUG_HIGH_ON) THEN
   PVX_UTILITY_PVT.debug_message('check_Qsnr_element_Uk_Items');
   END IF;

   check_Qsnr_element_Uk_Items(
      p_qsnr_element_rec => p_qsnr_element_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      return;
   END IF;

   -- Check Items Required/NOT NULL API calls

   IF (PV_DEBUG_HIGH_ON) THEN
   PVX_UTILITY_PVT.debug_message('check_qsnr_element_req_items');
   END IF;

   check_qsnr_element_req_items(
      p_qsnr_element_rec => p_qsnr_element_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      return;
   END IF;
   -- Check Items Foreign Keys API calls

   IF (PV_DEBUG_HIGH_ON) THEN
   PVX_UTILITY_PVT.debug_message('check_qsnr_element_FK_items');
   END IF;

   check_qsnr_element_FK_items(
      p_qsnr_element_rec => p_qsnr_element_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      return;
   END IF;
   -- Check Items Lookups

   IF (PV_DEBUG_HIGH_ON) THEN
   PVX_UTILITY_PVT.debug_message('check_qs_elemnt_Lookup_items');
   END IF;

   check_qs_elemnt_Lookup_items(
      p_qsnr_element_rec => p_qsnr_element_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      return;
   END IF;
END Check_qsnr_element_Items;





PROCEDURE Complete_Qsnr_Element_Rec (
   p_qsnr_element_rec IN qsnr_element_rec_type,
   x_complete_rec OUT NOCOPY qsnr_element_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_ge_qsnr_elements_b
      WHERE qsnr_element_id = p_qsnr_element_rec.qsnr_element_id;
   l_qsnr_element_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_qsnr_element_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_qsnr_element_rec;
   CLOSE c_complete;

   -- qsnr_element_id
   IF p_qsnr_element_rec.qsnr_element_id IS NULL THEN
      x_complete_rec.qsnr_element_id := l_qsnr_element_rec.qsnr_element_id;
   END IF;

   -- object_version_number
   IF p_qsnr_element_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_qsnr_element_rec.object_version_number;
   END IF;

   -- arc_used_by_entity_code
   IF p_qsnr_element_rec.arc_used_by_entity_code IS NULL THEN
      x_complete_rec.arc_used_by_entity_code := l_qsnr_element_rec.arc_used_by_entity_code;
   END IF;

   -- used_by_entity_id
   IF p_qsnr_element_rec.used_by_entity_id IS NULL THEN
      x_complete_rec.used_by_entity_id := l_qsnr_element_rec.used_by_entity_id;
   END IF;

   -- qsnr_elmt_seq_num
   IF p_qsnr_element_rec.qsnr_elmt_seq_num IS NULL THEN
      x_complete_rec.qsnr_elmt_seq_num := l_qsnr_element_rec.qsnr_elmt_seq_num;
   END IF;

   -- qsnr_elmt_type
   IF p_qsnr_element_rec.qsnr_elmt_type IS NULL THEN
      x_complete_rec.qsnr_elmt_type := l_qsnr_element_rec.qsnr_elmt_type;
   END IF;

   -- entity_attr_id
   IF p_qsnr_element_rec.entity_attr_id IS NULL THEN
      x_complete_rec.entity_attr_id := l_qsnr_element_rec.entity_attr_id;
   END IF;

   -- qsnr_elmt_page_num
   IF p_qsnr_element_rec.qsnr_elmt_page_num IS NULL THEN
      x_complete_rec.qsnr_elmt_page_num := l_qsnr_element_rec.qsnr_elmt_page_num;
   END IF;

   -- is_required_flag
   IF p_qsnr_element_rec.is_required_flag IS NULL THEN
      x_complete_rec.is_required_flag := l_qsnr_element_rec.is_required_flag;
   END IF;

   -- created_by
   IF p_qsnr_element_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_qsnr_element_rec.created_by;
   END IF;

   -- creation_date
   IF p_qsnr_element_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_qsnr_element_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_qsnr_element_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_qsnr_element_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_qsnr_element_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_qsnr_element_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_qsnr_element_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_qsnr_element_rec.last_update_login;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Qsnr_Element_Rec;




PROCEDURE Default_Qsnr_Element_Items ( p_qsnr_element_rec IN qsnr_element_rec_type ,
                                x_qsnr_element_rec OUT NOCOPY qsnr_element_rec_type )
IS
   l_qsnr_element_rec qsnr_element_rec_type := p_qsnr_element_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Gq_Elements(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_qsnr_element_rec               IN   qsnr_element_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Gq_Elements';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_qsnr_element_rec        qsnr_element_rec_type;
l_qsnr_element_rec_out    qsnr_element_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_gq_elements_;

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

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_UTILITY_PVT.debug_message('Check_qsnr_element_Items');

      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_qsnr_element_Items(
                 p_qsnr_element_rec        => p_qsnr_element_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Qsnr_Element_Items (p_qsnr_element_rec => p_qsnr_element_rec ,
                                x_qsnr_element_rec => l_qsnr_element_rec) ;
      END IF ;

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_UTILITY_PVT.debug_message('Complete_qsnr_element_Rec');

      END IF;

      Complete_qsnr_element_Rec(
         p_qsnr_element_rec        => l_qsnr_element_rec,
         x_complete_rec            => l_qsnr_element_rec_out
      );

      l_qsnr_element_rec := l_qsnr_element_rec_out;

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_UTILITY_PVT.debug_message('Validate_qsnr_element_Rec');

      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_qsnr_element_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_qsnr_element_rec           =>    l_qsnr_element_rec);
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Validate_qsnr_element_Rec end.....');
      END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Gq_Elements_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Gq_Elements_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Gq_Elements_;
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
End Validate_Gq_Elements;


PROCEDURE Validate_Qsnr_Element_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_qsnr_element_rec               IN    qsnr_element_rec_type
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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_qsnr_element_Rec;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Move_Qsnr_Element
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_qsnr_element_id         IN   NUMBER
--       p_object_version_number   IN  NUMBER
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Move_Qsnr_Element (
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_qsnr_element_rec           IN   qsnr_element_rec_type
    ,p_movement                   IN   VARCHAR2
    )

IS

   CURSOR c_get_used_by_entity (cv_qsnr_element_id NUMBER) IS
      select arc_used_by_entity_code, used_by_entity_id, qsnr_elmt_seq_num
      from pv_ge_qsnr_elements_vl
      where qsnr_element_id = cv_qsnr_element_id;

   CURSOR c_get_qsnr (cv_qsnr_elmt_seq_num NUMBER,
                      cv_arc_used_by_entity_code VARCHAR2,
                      cv_used_by_entity_id NUMBER) IS
      SELECT *
      FROM PV_GE_QSNR_ELEMENTS_VL
      WHERE qsnr_elmt_seq_num = cv_qsnr_elmt_seq_num
            AND arc_used_by_entity_code = cv_arc_used_by_entity_code
            AND used_by_entity_id = cv_used_by_entity_id;

   l_api_name                  CONSTANT VARCHAR2(30) := 'Move_Up';
   l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_api_version_number        CONSTANT NUMBER       := 1.0;
   l_current_qsnr_rec          c_get_qsnr%ROWTYPE;
   l_up_qsnr_rec               c_get_qsnr%ROWTYPE;
   l_temp                      NUMBER;
   --l_current_qsnr_element_rec  qsnr_element_rec_type := g_miss_qsnr_element_rec;
   l_current_qsnr_element_rec  qsnr_element_rec_type := p_qsnr_element_rec;
   l_up_qsnr_element_rec       qsnr_element_rec_type := g_miss_qsnr_element_rec;
   l_get_used_by_entity        c_get_used_by_entity%ROWTYPE;
   l_object_version_number     NUMBER;

BEGIN

      ---- Initialize----------------

      -- Standard Start of API savepoint
      SAVEPOINT Move_Qsnr_Element;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number
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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Start to move');
      END IF;

      OPEN c_get_used_by_entity(p_qsnr_element_rec.qsnr_element_id);
      FETCH c_get_used_by_entity INTO l_get_used_by_entity;
      CLOSE c_get_used_by_entity;

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_UTILITY_PVT.debug_message( 'qsnr_elmt_seq_num = ' || l_get_used_by_entity.qsnr_elmt_seq_num);

      END IF;
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'arc_used_by_entity_code = ' || l_get_used_by_entity.arc_used_by_entity_code);
      END IF;
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'used_by_entity_id = ' || l_get_used_by_entity.used_by_entity_id);
      END IF;

      OPEN c_get_qsnr(l_get_used_by_entity.qsnr_elmt_seq_num,
                      l_get_used_by_entity.arc_used_by_entity_code,
                      l_get_used_by_entity.used_by_entity_id);
      FETCH c_get_qsnr INTO l_current_qsnr_rec;
      CLOSE c_get_qsnr;


      -- move up: get the above record
      -- move down: get the next record
      IF p_movement = 'U' THEN
         OPEN c_get_qsnr(l_get_used_by_entity.qsnr_elmt_seq_num - 1,
                      l_get_used_by_entity.arc_used_by_entity_code,
                      l_get_used_by_entity.used_by_entity_id);
      ELSIF p_movement = 'D' THEN
         OPEN c_get_qsnr(l_get_used_by_entity.qsnr_elmt_seq_num + 1,
                      l_get_used_by_entity.arc_used_by_entity_code,
                      l_get_used_by_entity.used_by_entity_id);
      END IF;
         FETCH c_get_qsnr INTO l_up_qsnr_rec;
         CLOSE c_get_qsnr;


      IF (PV_DEBUG_HIGH_ON) THEN





      PVX_UTILITY_PVT.debug_message('qsnr_elmt_type = ' || l_current_qsnr_rec.qsnr_elmt_type);


      END IF;
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('qsnr_elmt_type = ' || l_up_qsnr_rec.qsnr_elmt_type);
      END IF;

      IF l_up_qsnr_rec.qsnr_elmt_type <> 'PAGEBREAK'
         AND l_current_qsnr_rec.qsnr_elmt_type <> 'PAGEBREAK' THEN
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('None is Page Break');
         END IF;

         l_up_qsnr_element_rec.qsnr_element_id := l_up_qsnr_rec.qsnr_element_id;
         l_up_qsnr_element_rec.object_version_number := l_up_qsnr_rec.object_version_number;
         l_current_qsnr_element_rec.qsnr_element_id := l_current_qsnr_rec.qsnr_element_id;
         l_current_qsnr_element_rec.object_version_number := l_current_qsnr_rec.object_version_number;

         -- Exchange qsnr_elmt_seq
         l_up_qsnr_element_rec.qsnr_elmt_seq_num := l_current_qsnr_rec.qsnr_elmt_seq_num;
         l_current_qsnr_element_rec.qsnr_elmt_seq_num := l_up_qsnr_rec.qsnr_elmt_seq_num;

         Update_Gq_Elements( p_api_version_number     => 1.0,
                             p_init_msg_list          => FND_API.G_FALSE,
                             p_validation_level       => p_validation_level,
                             p_commit                 => p_commit,
                             x_return_status          => x_return_status,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data,
                             p_qsnr_element_rec       => l_current_qsnr_element_rec,
                             x_object_version_number  => l_object_version_number
                             );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         Update_Gq_Elements( p_api_version_number     => 1.0,
                             p_init_msg_list          => FND_API.G_FALSE,
                             p_validation_level       => p_validation_level,
                             p_commit                 => p_commit,
                             x_return_status          => x_return_status,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data,
                             p_qsnr_element_rec       => l_up_qsnr_element_rec,
                             x_object_version_number  => l_object_version_number
                             );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

      ELSIF l_current_qsnr_rec.qsnr_elmt_type = 'PAGEBREAK'
         AND l_up_qsnr_rec.qsnr_elmt_type <> 'PAGEBREAK' THEN
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('Current is Page Break');
         END IF;

         l_up_qsnr_element_rec.qsnr_element_id := l_up_qsnr_rec.qsnr_element_id;
         l_up_qsnr_element_rec.object_version_number := l_up_qsnr_rec.object_version_number;
         l_current_qsnr_element_rec.qsnr_element_id := l_current_qsnr_rec.qsnr_element_id;
         l_current_qsnr_element_rec.object_version_number := l_current_qsnr_rec.object_version_number;

         -- Exchange qsnr_elmt_seq
         l_up_qsnr_element_rec.qsnr_elmt_seq_num := l_current_qsnr_rec.qsnr_elmt_seq_num;
         l_current_qsnr_element_rec.qsnr_elmt_seq_num := l_up_qsnr_rec.qsnr_elmt_seq_num;

         -- Modify the qsnr_elmt_page_num field
         IF p_movement = 'U' THEN
            l_up_qsnr_element_rec.qsnr_elmt_page_num := l_up_qsnr_rec.qsnr_elmt_page_num + 1;
         ELSIF p_movement = 'D' THEN
            l_up_qsnr_element_rec.qsnr_elmt_page_num := l_up_qsnr_rec.qsnr_elmt_page_num - 1;
         END IF;
         l_current_qsnr_element_rec.qsnr_elmt_page_num := l_current_qsnr_rec.qsnr_elmt_page_num;

         Update_Gq_Elements( p_api_version_number     => 1.0,
                             p_init_msg_list          => FND_API.G_FALSE,
                             p_validation_level       => p_validation_level,
                             p_commit                 => p_commit,
                             x_return_status          => x_return_status,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data,
                             p_qsnr_element_rec       => l_current_qsnr_element_rec,
                             x_object_version_number  => l_object_version_number
                             );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         Update_Gq_Elements( p_api_version_number     => 1.0,
                             p_init_msg_list          => FND_API.G_FALSE,
                             p_validation_level       => p_validation_level,
                             p_commit                 => p_commit,
                             x_return_status          => x_return_status,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data,
                             p_qsnr_element_rec       => l_up_qsnr_element_rec,
                             x_object_version_number  => l_object_version_number
                             );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

      ELSIF l_up_qsnr_rec.qsnr_elmt_type = 'PAGEBREAK'
         AND l_current_qsnr_rec.qsnr_elmt_type <> 'PAGEBREAK' THEN
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('Up is Page Break');
         END IF;

         l_up_qsnr_element_rec.qsnr_element_id := l_up_qsnr_rec.qsnr_element_id;
         l_up_qsnr_element_rec.object_version_number := l_up_qsnr_rec.object_version_number;
         l_current_qsnr_element_rec.qsnr_element_id := l_current_qsnr_rec.qsnr_element_id;
         l_current_qsnr_element_rec.object_version_number := l_current_qsnr_rec.object_version_number;

         -- Exchange qsnr_elmt_seq_num
         l_up_qsnr_element_rec.qsnr_elmt_seq_num := l_current_qsnr_rec.qsnr_elmt_seq_num;
         l_current_qsnr_element_rec.qsnr_elmt_seq_num := l_up_qsnr_rec.qsnr_elmt_seq_num;

         -- Modify the qsnr_elmt_page_num field
         l_up_qsnr_element_rec.qsnr_elmt_page_num := l_up_qsnr_rec.qsnr_elmt_page_num;
         IF p_movement = 'U' THEN
            l_current_qsnr_element_rec.qsnr_elmt_page_num := l_current_qsnr_rec.qsnr_elmt_page_num - 1;
         ELSIF p_movement = 'D' THEN
            l_current_qsnr_element_rec.qsnr_elmt_page_num := l_current_qsnr_rec.qsnr_elmt_page_num + 1;
         END IF;

         IF (PV_DEBUG_HIGH_ON) THEN



         PVX_UTILITY_PVT.debug_message('l_up_qsnr_element_rec.qsnr_elmt_seq_num' || l_up_qsnr_element_rec.qsnr_elmt_seq_num);

         END IF;
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('l_current_qsnr_rec.qsnr_elmt_seq_num' || l_current_qsnr_rec.qsnr_elmt_seq_num);
         END IF;


         Update_Gq_Elements( p_api_version_number     => 1.0,
                             p_init_msg_list          => FND_API.G_FALSE,
                             p_validation_level       => p_validation_level,
                             p_commit                 => p_commit,
                             x_return_status          => x_return_status,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data,
                             p_qsnr_element_rec       => l_current_qsnr_element_rec,
                             x_object_version_number  => l_object_version_number
                             );

         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         Update_Gq_Elements( p_api_version_number     => 1.0,
                             p_init_msg_list          => FND_API.G_FALSE,
                             p_validation_level       => p_validation_level,
                             p_commit                 => p_commit,
                             x_return_status          => x_return_status,
                             x_msg_count              => x_msg_count,
                             x_msg_data               => x_msg_data,
                             p_qsnr_element_rec       => l_up_qsnr_element_rec,
                             x_object_version_number  => l_object_version_number
                             );

         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Move_Qsnr_Element;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Move_Qsnr_Element;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO Move_Qsnr_Element;
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

END Move_Qsnr_Element;

END PV_Gq_Elements_PVT;

/
