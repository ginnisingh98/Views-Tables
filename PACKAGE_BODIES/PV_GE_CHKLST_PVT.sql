--------------------------------------------------------
--  DDL for Package Body PV_GE_CHKLST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_CHKLST_PVT" as
/* $Header: pvxvgcib.pls 120.2 2005/08/26 10:19:32 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Chklst_PVT
-- Purpose
--
-- History
--  15 Nov 2002  anubhavk created
--  19 Nov 2002 anubhavk  Updated - For NOCOPY by running nocopy.sh
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Ge_Chklst_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvgcib.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Ge_Chklst_Items (
   p_ge_chklst_rec IN  ge_chklst_rec_type ,
   x_ge_chklst_rec OUT NOCOPY ge_chklst_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ge_Chklst
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
--       p_ge_chklst_rec            IN   ge_chklst_rec_type  Required
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

PROCEDURE Create_Ge_Chklst(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ge_chklst_rec              IN   ge_chklst_rec_type  := g_miss_ge_chklst_rec,
    x_checklist_item_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ge_Chklst';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_checklist_item_id              NUMBER;
   l_dummy                     NUMBER;
   l_ge_chklst_rec       ge_chklst_rec_type  := p_ge_chklst_rec;
   l_sequence_num              NUMBER :=0;
   CURSOR c_id IS
      SELECT pv_ge_chklst_items_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_GE_CHKLST_ITEMS_B
      WHERE checklist_item_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_ge_chklst_pvt;

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

	 IF p_ge_chklst_rec.checklist_item_id IS NULL OR p_ge_chklst_rec.checklist_item_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         --FETCH c_id INTO l_checklist_item_id; anubhav changed to
	 FETCH c_id INTO l_ge_chklst_rec.checklist_item_id;
         CLOSE c_id;

         --OPEN c_id_exists(l_checklist_item_id);
	OPEN c_id_exists(l_ge_chklst_rec.checklist_item_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         --l_checklist_item_id := p_pgc_items_rec.checklist_item_id;
	 l_ge_chklst_rec.checklist_item_id := p_ge_chklst_rec.checklist_item_id;
   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Ge_Chklst');
          END IF;

       -- Populate the default required items Anubhav
           l_ge_chklst_rec.last_update_date      := SYSDATE;
           l_ge_chklst_rec.last_updated_by       := FND_GLOBAL.user_id;
           l_ge_chklst_rec.creation_date         := SYSDATE;
           l_ge_chklst_rec.created_by            := FND_GLOBAL.user_id;
           l_ge_chklst_rec.last_update_login     := FND_GLOBAL.conc_login_id;
           l_ge_chklst_rec.object_version_number := l_object_version_number;

          -- Invoke validation procedures
          Validate_ge_chklst(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            --p_ge_chklst_rec  =>  p_ge_chklst_rec,
	    p_ge_chklst_rec  =>  l_ge_chklst_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Adding the call to get the latest sequence number
      FOR cur IN (SELECT MAX(sequence_num) temp_sequence_num from pv_ge_chklst_items_vl where (used_by_entity_id = p_ge_chklst_rec.used_by_entity_id ))
      LOOP

      l_sequence_num := cur.temp_sequence_num;
      END LOOP;

      l_sequence_num := NVL(l_sequence_num,0) +1 ;


      -- Invoke table handler(Pv_Ge_Chklst_Pkg.Insert_Row)
      Pv_Ge_Chklst_Pkg.Insert_Row(
          px_checklist_item_id  => l_ge_chklst_rec.checklist_item_id,
          px_object_version_number  => l_object_version_number,
          p_arc_used_by_entity_code  => p_ge_chklst_rec.arc_used_by_entity_code,
          p_used_by_entity_id  => p_ge_chklst_rec.used_by_entity_id,
          p_sequence_num  => l_sequence_num,
          p_is_required_flag  => p_ge_chklst_rec.is_required_flag,
          p_enabled_flag  => p_ge_chklst_rec.enabled_flag,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_checklist_item_name  => p_ge_chklst_rec.checklist_item_name
);

          x_checklist_item_id := l_checklist_item_id;
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

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Ge_Chklst_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ge_Chklst_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ge_Chklst_PVT;
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
End Create_Ge_Chklst;

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


   CURSOR c_get_chklst_rec (cv_program_id IN NUMBER)  IS
       SELECT  sequence_num, is_required_flag, enabled_flag
       FROM    pv_ge_chklst_items_b
       WHERE   arc_used_by_entity_code = 'PRGM' AND used_by_entity_id = cv_program_id
       order by checklist_item_id;

   CURSOR c_get_chklst_tl_rec (cv_program_id IN NUMBER)  IS
      SELECT  tl.checklist_item_id, checklist_item_name, source_lang, language
      FROM    pv_ge_chklst_items_b b, pv_ge_chklst_items_tl tl
      WHERE   b.checklist_item_id = tl.checklist_item_id
      AND     b.arc_used_by_entity_code = 'PRGM'
      AND     b.used_by_entity_id = cv_program_id
      order by tl.checklist_item_id;

   CURSOR c_id IS
      SELECT pv_ge_chklst_items_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM pv_ge_chklst_items_b
      WHERE checklist_item_id = l_id;

   l_checklist_item_id              NUMBER;
   l_object_version_number          NUMBER;
   L_API_NAME                       CONSTANT VARCHAR2(30) := 'Copy_Row - Checklist';
   L_API_VERSION_NUMBER             CONSTANT NUMBER   := 1.0;

   l_dummy 					  NUMBER;
   elmt_count				NUMBER;

   type numArray is table of number index by binary_integer;
   type varcharArray is table of VARCHAR2(240) index by binary_integer;

   checklist_item_id_array numArray;
   old_checklist_item_id_array numArray;
   new_checklist_item_id_array numArray;
   sequence_num_array numArray;
   is_required_flag_array varcharArray;
   enabled_flag_array varcharArray;
   checklist_item_name_array varcharArray;
   source_lang_array varcharArray;
   language_array varcharArray;

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


   OPEN c_get_chklst_rec (p_src_object_id);
   LOOP
   PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' : inside loop');
   FETCH c_get_chklst_rec  bulk collect into
    sequence_num_array, is_required_flag_array, enabled_flag_array
    LIMIT 100;
    PVX_UTILITY_PVT.debug_message(l_api_name || 'sequence_num_array.count =' || to_char(sequence_num_array.count));

     for i in 1..sequence_num_array.count  LOOP
	 PVX_UTILITY_PVT.debug_message(l_api_name || 'testing1');

         l_dummy := NULL;
         OPEN c_id;
		 LOOP
		 	 PVX_UTILITY_PVT.debug_message(l_api_name || 'testing2');
	 	 		 FETCH c_id INTO checklist_item_id_array(i);
		 		 OPEN c_id_exists(checklist_item_id_array(i));
		 	  	 	  FETCH c_id_exists INTO l_dummy;
		 		 CLOSE c_id_exists;
		 		 EXIT WHEN l_dummy IS NULL;
		 END LOOP;
         CLOSE c_id;
		 PVX_UTILITY_PVT.debug_message(l_api_name || 'checklist_item_id_array(i) =' || to_char(checklist_item_id_array(i)));

      END LOOP;


      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' : insert into b table');

      forall i in 1..checklist_item_id_array.count
      INSERT INTO pv_ge_chklst_items_b(
           checklist_item_id,
           object_version_number,
           arc_used_by_entity_code,
           used_by_entity_id,
           sequence_num,
           is_required_flag,
           enabled_flag,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
	   )
	   VALUES
	   (
           checklist_item_id_array(i),
           1,
           'PRGM',
           p_tar_object_id,
           sequence_num_array(i),
           is_required_flag_array(i),
           enabled_flag_array(i),
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.CONC_LOGIN_ID
	   );

	   exit when c_get_chklst_rec%notfound;
     END LOOP;
    Close c_get_chklst_rec;


     open c_get_chklst_tl_rec(p_src_object_id);
     LOOP

      Fetch c_get_chklst_tl_rec bulk collect into
	  old_checklist_item_id_array, checklist_item_name_array, source_lang_array, language_array limit 100;

      	  elmt_count := 1;
	  for k in 1..old_checklist_item_id_array.count loop
	  	  if ((k <> 1) and (old_checklist_item_id_array(k) <> old_checklist_item_id_array(k-1))) then
	      	  elmt_count := elmt_count + 1;
	  	  end if;
		  PVX_UTILITY_PVT.debug_message(l_api_name || 'k = ' || to_char(k));
		  PVX_UTILITY_PVT.debug_message(l_api_name || 'elmt_count = ' || to_char(elmt_count));
	  	  new_checklist_item_id_array(k) := checklist_item_id_array(elmt_count);

	  end loop;

      Forall j in 1..old_checklist_item_id_array.count
	  --PVX_UTILITY_PVT.debug_message(l_api_name || 'insert into pv_checklist_items_tl');
      INSERT INTO pv_ge_chklst_items_tl(
           checklist_item_id,
           language ,
           last_update_date ,
           last_updated_by ,
           creation_date ,
           created_by ,
           last_update_login ,
           source_lang ,
           checklist_item_name
      )
      values
      (
           new_checklist_item_id_array(j),
           language_array(j),
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           FND_GLOBAL.CONC_LOGIN_ID,
           source_lang_array(j),
           checklist_item_name_array(j)
     );

	 exit when c_get_chklst_tl_rec%notfound;
	 END LOOP;
     close c_get_chklst_tl_rec;

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
--           Update_Ge_Chklst
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
--       p_ge_chklst_rec            IN   ge_chklst_rec_type  Required
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

PROCEDURE Update_Ge_Chklst(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ge_chklst_rec               IN    ge_chklst_rec_type
    )

 IS


CURSOR c_get_ge_chklst(checklist_item_id NUMBER) IS
    SELECT *
    FROM  PV_GE_CHKLST_ITEMS_B
    WHERE  checklist_item_id = p_ge_chklst_rec.checklist_item_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ge_Chklst';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_checklist_item_id    NUMBER;
l_ref_ge_chklst_rec  c_get_Ge_Chklst%ROWTYPE ;
l_tar_ge_chklst_rec  ge_chklst_rec_type := P_ge_chklst_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_ge_chklst_pvt;

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

      OPEN c_get_Ge_Chklst( l_tar_ge_chklst_rec.checklist_item_id);

      FETCH c_get_Ge_Chklst INTO l_ref_ge_chklst_rec  ;

       If ( c_get_Ge_Chklst%NOTFOUND) THEN
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Ge_Chklst') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Ge_Chklst;


      If (l_tar_ge_chklst_rec.object_version_number is NULL or
          l_tar_ge_chklst_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ge_chklst_rec.object_version_number <> l_ref_ge_chklst_rec.object_version_number) Then
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ge_Chklst') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Ge_Chklst');
          END IF;

          -- Invoke validation procedures
          Validate_ge_chklst(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_ge_chklst_rec  =>  p_ge_chklst_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      --IF (PV_DEBUG_HIGH_ON) THENPVX_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');END IF;

      -- Invoke table handler(Pv_Ge_Chklst_Pkg.Update_Row)
      Pv_Ge_Chklst_Pkg.Update_Row(
          p_checklist_item_id  => p_ge_chklst_rec.checklist_item_id,
          p_object_version_number  => p_ge_chklst_rec.object_version_number,
          p_arc_used_by_entity_code  => p_ge_chklst_rec.arc_used_by_entity_code,
          p_used_by_entity_id  => p_ge_chklst_rec.used_by_entity_id,
          p_sequence_num  => p_ge_chklst_rec.sequence_num,
          p_is_required_flag  => p_ge_chklst_rec.is_required_flag,
          p_enabled_flag  => p_ge_chklst_rec.enabled_flag,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_checklist_item_name  => p_ge_chklst_rec.checklist_item_name
);
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

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Ge_Chklst_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ge_Chklst_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ge_Chklst_PVT;
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
End Update_Ge_Chklst;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ge_Chklst
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
--       p_checklist_item_id                IN   NUMBER
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

PROCEDURE Delete_Ge_Chklst(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_checklist_item_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ge_Chklst';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_ge_chklst_pvt;

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
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(Pv_Ge_Chklst_Pkg.Delete_Row)
      Pv_Ge_Chklst_Pkg.Delete_Row(
          p_checklist_item_id  => p_checklist_item_id,
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

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Ge_Chklst_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ge_Chklst_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ge_Chklst_PVT;
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
End Delete_Ge_Chklst;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ge_Chklst
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
--       p_ge_chklst_rec            IN   ge_chklst_rec_type  Required
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

PROCEDURE Lock_Ge_Chklst(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_checklist_item_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ge_Chklst';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_checklist_item_id                  NUMBER;

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
Pv_Ge_Chklst_Pkg.Lock_Row(l_checklist_item_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (PV_DEBUG_HIGH_ON) THEN

  PVX_UTILITY_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Ge_Chklst_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ge_Chklst_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ge_Chklst_PVT;
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
End Lock_Ge_Chklst;




PROCEDURE check_Ge_Chklst_Uk_Items(
    p_ge_chklst_rec               IN   ge_chklst_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_ge_chklst_rec.checklist_item_id IS NOT NULL
      THEN
         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'pv_ge_chklst_items_b',
         'checklist_item_id = ''' || p_ge_chklst_rec.checklist_item_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_checklist_item_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Ge_Chklst_Uk_Items;



PROCEDURE check_Ge_Chklst_Req_Items(
    p_ge_chklst_rec               IN  ge_chklst_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ge_chklst_rec.checklist_item_id = FND_API.G_MISS_NUM OR p_ge_chklst_rec.checklist_item_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CHECKLIST_ITEM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.object_version_number = FND_API.G_MISS_NUM OR p_ge_chklst_rec.object_version_number IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.arc_used_by_entity_code = FND_API.g_miss_char OR p_ge_chklst_rec.arc_used_by_entity_code IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ARC_USED_BY_ENTITY_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.used_by_entity_id = FND_API.G_MISS_NUM OR p_ge_chklst_rec.used_by_entity_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'USED_BY_ENTITY_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.sequence_num = FND_API.G_MISS_NUM OR p_ge_chklst_rec.sequence_num IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'SEQUENCE_NUM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.is_required_flag = FND_API.g_miss_char OR p_ge_chklst_rec.is_required_flag IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'IS_REQUIRED_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.enabled_flag = FND_API.g_miss_char OR p_ge_chklst_rec.enabled_flag IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ENABLED_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_ge_chklst_rec.checklist_item_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CHECKLIST_ITEM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.object_version_number = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.arc_used_by_entity_code = FND_API.g_miss_char THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ARC_USED_BY_ENTITY_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.used_by_entity_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'USED_BY_ENTITY_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.sequence_num = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'SEQUENCE_NUM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.is_required_flag = FND_API.g_miss_char THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'IS_REQUIRED_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_chklst_rec.enabled_flag = FND_API.g_miss_char THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ENABLED_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Ge_Chklst_Req_Items;



PROCEDURE check_Ge_Chklst_Fk_Items(
    p_ge_chklst_rec IN ge_chklst_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Ge_Chklst_Fk_Items;



PROCEDURE check_Ge_Chklst_Lookup_Items(
    p_ge_chklst_rec IN ge_chklst_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Ge_Chklst_Lookup_Items;



PROCEDURE Check_Ge_Chklst_Items (
    P_ge_chklst_rec     IN    ge_chklst_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Ge_chklst_Uk_Items(
      p_ge_chklst_rec => p_ge_chklst_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_ge_chklst_req_items(
      p_ge_chklst_rec => p_ge_chklst_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_ge_chklst_FK_items(
      p_ge_chklst_rec => p_ge_chklst_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_ge_chklst_Lookup_items(
      p_ge_chklst_rec => p_ge_chklst_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_ge_chklst_Items;





PROCEDURE Complete_Ge_Chklst_Rec (
   p_ge_chklst_rec IN ge_chklst_rec_type,
   x_complete_rec OUT NOCOPY ge_chklst_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_ge_chklst_items_b
      WHERE checklist_item_id = p_ge_chklst_rec.checklist_item_id;
   l_ge_chklst_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ge_chklst_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ge_chklst_rec;
   CLOSE c_complete;

   -- checklist_item_id
   IF p_ge_chklst_rec.checklist_item_id IS NULL THEN
      x_complete_rec.checklist_item_id := l_ge_chklst_rec.checklist_item_id;
   END IF;

   -- object_version_number
   IF p_ge_chklst_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_ge_chklst_rec.object_version_number;
   END IF;

   -- arc_used_by_entity_code
   IF p_ge_chklst_rec.arc_used_by_entity_code IS NULL THEN
      x_complete_rec.arc_used_by_entity_code := l_ge_chklst_rec.arc_used_by_entity_code;
   END IF;

   -- used_by_entity_id
   IF p_ge_chklst_rec.used_by_entity_id IS NULL THEN
      x_complete_rec.used_by_entity_id := l_ge_chklst_rec.used_by_entity_id;
   END IF;

   -- sequence_num
   IF p_ge_chklst_rec.sequence_num IS NULL THEN
      x_complete_rec.sequence_num := l_ge_chklst_rec.sequence_num;
   END IF;

   -- is_required_flag
   IF p_ge_chklst_rec.is_required_flag IS NULL THEN
      x_complete_rec.is_required_flag := l_ge_chklst_rec.is_required_flag;
   END IF;

   -- enabled_flag
   IF p_ge_chklst_rec.enabled_flag IS NULL THEN
      x_complete_rec.enabled_flag := l_ge_chklst_rec.enabled_flag;
   END IF;

   -- created_by
   IF p_ge_chklst_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_ge_chklst_rec.created_by;
   END IF;

   -- creation_date
   IF p_ge_chklst_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_ge_chklst_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_ge_chklst_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_ge_chklst_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_ge_chklst_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_ge_chklst_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_ge_chklst_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_ge_chklst_rec.last_update_login;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Ge_Chklst_Rec;




PROCEDURE Default_Ge_Chklst_Items ( p_ge_chklst_rec IN ge_chklst_rec_type ,
                                x_ge_chklst_rec OUT NOCOPY ge_chklst_rec_type )
IS
   l_ge_chklst_rec ge_chklst_rec_type := p_ge_chklst_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Ge_Chklst(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ge_chklst_rec               IN   ge_chklst_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ge_Chklst';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ge_chklst_rec      ge_chklst_rec_type;
l_ge_chklst_rec_out  ge_chklst_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_ge_chklst_;

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
              Check_ge_chklst_Items(
                 p_ge_chklst_rec        => p_ge_chklst_rec,
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
         Default_Ge_Chklst_Items (p_ge_chklst_rec => p_ge_chklst_rec ,
                                x_ge_chklst_rec => l_ge_chklst_rec) ;
      END IF ;


      Complete_ge_chklst_Rec(
         p_ge_chklst_rec        => l_ge_chklst_rec,
         x_complete_rec         => l_ge_chklst_rec_out
      );

      l_ge_chklst_rec := l_ge_chklst_rec_out;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_ge_chklst_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_ge_chklst_rec           =>    l_ge_chklst_rec);

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

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Ge_Chklst_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ge_Chklst_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ge_Chklst_;
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
End Validate_Ge_Chklst;


PROCEDURE Validate_Ge_Chklst_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ge_chklst_rec               IN    ge_chklst_rec_type
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
END Validate_ge_chklst_Rec;

PROCEDURE Check_Item_In_Chklst_Resp (
   p_checklist_item_id      IN    NUMBER,
   x_response               OUT NOCOPY   NUMBER
)
IS
l_response     NUMBER;
BEGIN
l_response := 0;

FOR cur IN (SELECT 1 FROM pv_ge_chklst_responses WHERE checklist_item_id = p_checklist_item_id)
LOOP

l_response :=1;
EXIT WHEN l_response = 1;

END LOOP;

x_response := l_response;

END Check_Item_In_Chklst_Resp;




END PV_Ge_Chklst_PVT;

/
