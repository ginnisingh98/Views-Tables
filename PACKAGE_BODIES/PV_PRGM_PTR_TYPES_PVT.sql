--------------------------------------------------------
--  DDL for Package Body PV_PRGM_PTR_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRGM_PTR_TYPES_PVT" as
 /* $Header: pvxvprpb.pls 115.5 2003/01/17 00:51:31 speddu ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_PTR_TYPES_PVT
-- Purpose
--
-- History
--         28-FEB-2002    Paul.Ukken      Created
--         29-APR-2002    Peter.Nixon     Modified
--         14-JUN-2002    Karen.Tsao      Modified to reverse logic of G_MISS_XXX and NULL.
--
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_PRGM_PTR_TYPES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvprpb.pls';


PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Prgm_Ptr_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type  :=  g_miss_prgm_ptr_types_rec
    ,x_program_partner_types_id   OUT NOCOPY  NUMBER
    )

 IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'Create_Prgm_Ptr_Type';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status                       VARCHAR2(1);
   l_prgm_ptr_types_rec                  prgm_ptr_types_rec_type := p_prgm_ptr_types_rec;

   l_object_version_number               NUMBER                 := 1;
   l_uniqueness_check                    VARCHAR2(1);

   CURSOR c_prgm_ptr_types_id_seq IS
      SELECT PV_PROGRAM_PARTNER_TYPES_s.NEXTVAL
      FROM dual;

   CURSOR c_prgm_ptr_types_id_seq_exists (l_id IN NUMBER) IS
      SELECT 'X'
      FROM PV_PROGRAM_PARTNER_TYPES
      WHERE PROGRAM_PARTNER_TYPES_ID = l_id;

BEGIN
      ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PGM_TGT_PTR_TYP_PVT;

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

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

       --------------- validate -------------------------

      IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


   IF p_prgm_ptr_types_rec.program_partner_types_id IS NULL OR
      p_prgm_ptr_types_rec.program_partner_types_id = FND_API.g_miss_num THEN
      LOOP
         -- Get the identifier
         OPEN c_prgm_ptr_types_id_seq;
         FETCH c_prgm_ptr_types_id_seq INTO l_prgm_ptr_types_rec.program_partner_types_id;
         CLOSE c_prgm_ptr_types_id_seq;

         -- Check the uniqueness of the identifier
         OPEN c_prgm_ptr_types_id_seq_exists(l_prgm_ptr_types_rec.program_partner_types_id);
         FETCH c_prgm_ptr_types_id_seq_exists INTO l_uniqueness_check;
            -- Exit when the identifier uniqueness is established
            EXIT WHEN c_prgm_ptr_types_id_seq_exists%ROWCOUNT = 0;
         CLOSE c_prgm_ptr_types_id_seq_exists;
       END LOOP;
    END IF;

      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - program_partner_types_id = '|| l_prgm_ptr_types_rec.program_partner_types_id);
      END IF;

      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - Validate_Prgm_Ptr_Type');
          END IF;

          -- Populate the default required items
           l_prgm_ptr_types_rec.last_update_date      := SYSDATE;
           l_prgm_ptr_types_rec.last_updated_by       := FND_GLOBAL.user_id;
           l_prgm_ptr_types_rec.creation_date         := SYSDATE;
           l_prgm_ptr_types_rec.created_by            := FND_GLOBAL.user_id;
           l_prgm_ptr_types_rec.last_update_login     := FND_GLOBAL.conc_login_id;
           l_prgm_ptr_types_rec.object_version_number := l_object_version_number;

           -- Invoke validation procedures
           Validate_Prgm_Ptr_Type(
              p_api_version_number         => 1.0
             ,p_init_msg_list              => FND_API.G_FALSE
             ,p_validation_level           => p_validation_level
             ,p_validation_mode            => JTF_PLSQL_API.g_create
             ,p_prgm_ptr_types_rec         => l_prgm_ptr_types_rec
             ,x_return_status              => x_return_status
             ,x_msg_count                  => x_msg_count
             ,x_msg_data                   => x_msg_data
             );
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' -  Validate_Prgm_Ptr_Type return_status = ' || x_return_status );
          END IF;

      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: ' || l_full_name || ' -  Calling create table handler');
      END IF;

       -- Invoke table handler(PV_PRGM_PTR_TYPES_PKG.Insert_Row)
       PV_PRGM_PTR_TYPES_PKG.Insert_Row(
            px_program_partner_types_id => l_prgm_ptr_types_rec.program_partner_types_id
           ,p_PROGRAM_TYPE_ID     => l_prgm_ptr_types_rec.PROGRAM_TYPE_ID
           ,p_partner_type              => l_prgm_ptr_types_rec.partner_type
           ,p_last_update_date          => l_prgm_ptr_types_rec.last_update_date
           ,p_last_updated_by           => l_prgm_ptr_types_rec.last_updated_by
           ,p_creation_date             => l_prgm_ptr_types_rec.creation_date
           ,p_created_by                => l_prgm_ptr_types_rec.created_by
           ,p_last_update_login         => l_prgm_ptr_types_rec.last_update_login
           ,p_object_version_number     => l_object_version_number
           );

           x_program_partner_types_id := l_prgm_ptr_types_rec.program_partner_types_id;

         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

        FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_PGM_TGT_PTR_TYP_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
              p_encoded => FND_API.G_FALSE
             ,p_count   => x_msg_count
             ,p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_PGM_TGT_PTR_TYP_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
              p_encoded => FND_API.G_FALSE
             ,p_count   => x_msg_count
             ,p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO CREATE_PGM_TGT_PTR_TYP_PVT;
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
 End Create_Prgm_Ptr_Type;


 PROCEDURE Update_Prgm_Ptr_Type(
      p_api_version_number         IN   NUMBER
     ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
     ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
     ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

     ,x_return_status              OUT NOCOPY  VARCHAR2
     ,x_msg_count                  OUT NOCOPY  NUMBER
     ,x_msg_data                   OUT NOCOPY  VARCHAR2

     ,p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type
     )

  IS


 CURSOR c_get_pgm_tgt_ptr_typ(cv_program_partner_types_id NUMBER) IS
     SELECT *
     FROM  PV_PROGRAM_PARTNER_TYPES
     WHERE program_partner_types_id = cv_program_partner_types_id;

 l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Prgm_Ptr_Type';
 l_full_name                CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_api_version_number       CONSTANT NUMBER       := 1.0;

-- Local Variables
 l_ref_prgm_ptr_types_rec           c_get_Pgm_Tgt_Ptr_Typ%ROWTYPE ;
 l_tar_prgm_ptr_types_rec           PV_PRGM_PTR_TYPES_PVT.prgm_ptr_types_rec_type := p_prgm_ptr_types_rec;

  BEGIN
     ---------Initialize ------------------

      -- Standard Start of API savepoint
       SAVEPOINT UPDATE_PGM_TGT_PTR_TYP_PVT;

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

      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Open Cursor to Select');
      END IF;

       OPEN c_get_Pgm_Tgt_Ptr_Typ( l_tar_prgm_ptr_types_rec.program_partner_types_id);
       FETCH c_get_Pgm_Tgt_Ptr_Typ INTO l_ref_prgm_ptr_types_rec  ;

         If ( c_get_Pgm_Tgt_Ptr_Typ%NOTFOUND) THEN
           FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
           FND_MESSAGE.set_token('MODE','Update');
           FND_MESSAGE.set_token('ENTITY','Pgm_Tgt_Ptr_Typ');
           FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_prgm_ptr_types_rec.program_partner_types_id));
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Debug Message
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Close Cursor');
         END IF;
       CLOSE     c_get_Pgm_Tgt_Ptr_Typ;


       If (l_tar_prgm_ptr_types_rec.object_version_number is NULL or
           l_tar_prgm_ptr_types_rec.object_version_number = FND_API.G_MISS_NUM ) THEN

           FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
           FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
           FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
       If (l_tar_prgm_ptr_types_rec.object_version_number <> l_ref_prgm_ptr_types_rec.object_version_number) Then
           FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
           FND_MESSAGE.set_token('VALUE','Pgm_Tgt_Ptr_Typ');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
       End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: '||l_full_name||' - Validate_Prgm_Ptr_Type');
          END IF;


          -- Invoke validation procedures
           Validate_Prgm_Ptr_Type(
              p_api_version_number  => 1.0
             ,p_init_msg_list       => FND_API.G_FALSE
             ,p_validation_level    => p_validation_level
             ,p_validation_mode     => JTF_PLSQL_API.g_update
             ,p_prgm_ptr_types_rec  => p_prgm_ptr_types_rec
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             );
      END IF;

     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;

     -- replace g_miss_char/num/date with current column values
     Complete_Rec(
              p_prgm_ptr_types_rec  => p_prgm_ptr_types_rec
             ,x_complete_rec        => l_tar_prgm_ptr_types_rec
             );

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling update table handler');
     END IF;

     -- Invoke table handler(PV_PRGM_PTR_TYPES_PKG.Update_Row)
     PV_PRGM_PTR_TYPES_PKG.Update_Row(
            p_program_partner_types_id  => p_prgm_ptr_types_rec.program_partner_types_id
           ,p_PROGRAM_TYPE_ID     => p_prgm_ptr_types_rec.PROGRAM_TYPE_ID
           ,p_partner_type              => p_prgm_ptr_types_rec.partner_type
           ,p_last_update_date          => SYSDATE
           ,p_last_updated_by           => FND_GLOBAL.user_id
           ,p_last_update_login         => FND_GLOBAL.conc_login_id
           ,p_object_version_number     => p_prgm_ptr_types_rec.object_version_number
          );

     -- Check for commit
     IF FND_API.to_boolean(p_commit) THEN
        COMMIT;
     END IF;

    FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false
      ,p_count   => x_msg_count
      ,p_data    => x_msg_data
      );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_PGM_TGT_PTR_TYP_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
              p_encoded => FND_API.G_FALSE
             ,p_count   => x_msg_count
             ,p_data    => x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_PGM_TGT_PTR_TYP_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
              p_encoded => FND_API.G_FALSE
             ,p_count   => x_msg_count
             ,p_data    => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_PGM_TGT_PTR_TYP_PVT;
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

END Update_Prgm_Ptr_Type;



PROCEDURE Delete_Prgm_Ptr_Type(
      p_api_version_number         IN   NUMBER
     ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
     ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
     ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
     ,x_return_status              OUT NOCOPY  VARCHAR
     ,x_msg_count                  OUT NOCOPY  NUMBER
     ,x_msg_data                   OUT NOCOPY  VARCHAR2
     ,p_program_partner_types_id   IN   NUMBER
     ,p_object_version_number      IN   NUMBER
     )

  IS

 l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Prgm_Ptr_Type';
 l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_api_version_number        CONSTANT NUMBER       := 1.0;

  BEGIN

     ---- Initialize----------------

       -- Standard Start of API savepoint
       SAVEPOINT DELETE_PGM_TGT_PTR_TYP_PVT;

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

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

       -- Invoke table handler(PV_PRGM_PTR_TYPES_PKG.Delete_Row)
       PV_PRGM_PTR_TYPES_PKG.Delete_Row(
             p_program_partner_types_id  => p_program_partner_types_id
          ,p_object_version_number => p_object_version_number
          );

     -- Check for commit
     IF FND_API.to_boolean(p_commit) THEN
        COMMIT;
     END IF;

    FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false
      ,p_count   => x_msg_count
      ,p_data    => x_msg_data
      );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO DELETE_PGM_TGT_PTR_TYP_PVT;
       ROLLBACK TO DELETE_PGM_TGT_PTR_TYP_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
              p_encoded => FND_API.G_FALSE
             ,p_count   => x_msg_count
             ,p_data    => x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_PGM_TGT_PTR_TYP_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
              p_encoded => FND_API.G_FALSE
             ,p_count => x_msg_count
             ,p_data  => x_msg_data
             );

    WHEN OTHERS THEN
       ROLLBACK TO DELETE_PGM_TGT_PTR_TYP_PVT;
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

 End Delete_Prgm_Ptr_Type;




 PROCEDURE Lock_Prgm_Ptr_Type(
      p_api_version_number         IN   NUMBER
     ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

     ,x_return_status              OUT NOCOPY  VARCHAR2
     ,x_msg_count                  OUT NOCOPY  NUMBER
     ,x_msg_data                   OUT NOCOPY  VARCHAR2

     ,p_program_partner_types_id   IN  NUMBER
     ,p_object_version             IN  NUMBER
     )

  IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_Prgm_Ptr_Type';
 l_api_version_number        CONSTANT NUMBER       := 1.0;
 l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_program_partner_types_id           NUMBER;

 CURSOR c_Pgm_Tgt_Ptr_Typ IS
    SELECT PROGRAM_PARTNER_TYPES_ID
    FROM PV_PROGRAM_PARTNER_TYPES
    WHERE PROGRAM_PARTNER_TYPES_ID = p_PROGRAM_PARTNER_TYPES_ID
    AND object_version_number = p_object_version
    FOR UPDATE NOWAIT;

 BEGIN

       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - start');
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
   OPEN c_Pgm_Tgt_Ptr_Typ;

   FETCH c_Pgm_Tgt_Ptr_Typ INTO l_program_partner_types_id;

   IF (c_Pgm_Tgt_Ptr_Typ%NOTFOUND) THEN
     CLOSE c_Pgm_Tgt_Ptr_Typ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
        FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;

   CLOSE c_Pgm_Tgt_Ptr_Typ;

  -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
     );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

 EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
*/
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO LOCK_PGM_TGT_PTR_TYP_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
              p_encoded => FND_API.G_FALSE
             ,p_count   => x_msg_count
             ,p_data    => x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO LOCK_Pgm_Tgt_Ptr_Typ_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
              p_encoded => FND_API.G_FALSE
             ,p_count => x_msg_count
             ,p_data  => x_msg_data
             );

    WHEN OTHERS THEN
      ROLLBACK TO LOCK_PGM_TGT_PTR_TYP_PVT;
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
 End Lock_Prgm_Ptr_Type;


 PROCEDURE Check_UK_Items(
      p_prgm_ptr_types_rec         IN  prgm_ptr_types_rec_type
     ,p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create
     ,x_return_status              OUT NOCOPY VARCHAR2
     )

IS

l_valid_flag  VARCHAR2(1);

BEGIN

       x_return_status := FND_API.g_ret_sts_success;
       IF p_validation_mode = JTF_PLSQL_API.g_create THEN

          l_valid_flag := PVX_Utility_PVT.check_uniqueness(
           'PV_PROGRAM_PARTNER_TYPES'
          ,'PROGRAM_PARTNER_TYPES_ID = ''' || p_prgm_ptr_types_rec.PROGRAM_PARTNER_TYPES_ID ||''''
          );

         IF l_valid_flag = FND_API.g_false THEN
           FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
           FND_MESSAGE.set_token('ID',to_char(p_prgm_ptr_types_rec.PROGRAM_PARTNER_TYPES_ID) );
           FND_MESSAGE.set_token('ENTITY','Pgm_Tgt_Ptr_Typ');
           FND_MSG_PUB.add;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
         END IF;

      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('- In Check_UK_Items API Before PROGRAM_TYPE_ID check' );
      END IF;

          l_valid_flag := PVX_Utility_PVT.check_uniqueness(
           'PV_PROGRAM_PARTNER_TYPES'
          ,'PROGRAM_TYPE_ID = ''' || p_prgm_ptr_types_rec.PROGRAM_TYPE_ID ||''' AND PARTNER_TYPE = ''' || p_prgm_ptr_types_rec.PARTNER_TYPE || ''''
          );

         IF l_valid_flag = FND_API.g_false THEN
           FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
           FND_MESSAGE.set_token('ID',to_char(p_prgm_ptr_types_rec.PROGRAM_TYPE_ID) );
           FND_MESSAGE.set_token('ENTITY','Pgm_Tgt_Ptr_Typ');
           FND_MSG_PUB.add;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
         END IF;
       END IF;

END Check_UK_Items;



PROCEDURE Check_Req_Items(
      p_prgm_ptr_types_rec         IN  prgm_ptr_types_rec_type
     ,p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create
     ,x_return_status              OUT NOCOPY VARCHAR2
     )

IS

BEGIN

    x_return_status := FND_API.g_ret_sts_success;

    IF p_validation_mode = JTF_PLSQL_API.g_create THEN

       IF p_prgm_ptr_types_rec.program_partner_types_id = FND_API.g_miss_num
       OR p_prgm_ptr_types_rec.program_partner_types_id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','PROGRAM_PARTNER_TYPES_ID');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_prgm_ptr_types_rec.PROGRAM_TYPE_ID = FND_API.g_miss_num
         OR p_prgm_ptr_types_rec.PROGRAM_TYPE_ID IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','PROGRAM_TYPE_ID');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_prgm_ptr_types_rec.partner_type = FND_API.g_miss_char
         OR  p_prgm_ptr_types_rec.partner_type IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','PARTNER_TYPE');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_prgm_ptr_types_rec.last_update_date = FND_API.g_miss_date
          OR p_prgm_ptr_types_rec.last_update_date IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','LAST_UPDATE_DATE');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_prgm_ptr_types_rec.last_updated_by = FND_API.g_miss_num
         OR p_prgm_ptr_types_rec.last_updated_by IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','LAST_UPDATED_BY');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_prgm_ptr_types_rec.creation_date = FND_API.g_miss_date
          OR p_prgm_ptr_types_rec.creation_date IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','CREATION_DATE');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_prgm_ptr_types_rec.created_by = FND_API.g_miss_num
          OR p_prgm_ptr_types_rec.created_by IS NULL THEN

          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','CREATED_BY');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_prgm_ptr_types_rec.last_update_login = FND_API.g_miss_num
          OR p_prgm_ptr_types_rec.last_update_login IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','LAST_UPDATE_LOGIN');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_prgm_ptr_types_rec.object_version_number = FND_API.g_miss_num
          OR p_prgm_ptr_types_rec.object_version_number IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
    ELSE


       IF p_prgm_ptr_types_rec.program_partner_types_id IS NULL THEN
           FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
           FND_MESSAGE.set_token('COLUMN','PROGRAM_PARTNER_TYPES_ID');
           FND_MSG_PUB.add;
            x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_prgm_ptr_types_rec.object_version_number IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
    END IF;

END Check_Req_Items;



PROCEDURE Check_FK_Items(
      p_prgm_ptr_types_rec IN prgm_ptr_types_rec_type
     ,x_return_status OUT NOCOPY VARCHAR2
     )
IS
BEGIN
    x_return_status := FND_API.g_ret_sts_success;

 ----------------------- PROGRAM_TYPE_ID ------------------------
 IF (p_prgm_ptr_types_rec.PROGRAM_TYPE_ID <> FND_API.g_miss_num and
     p_prgm_ptr_types_rec.PROGRAM_TYPE_ID IS NOT NULL ) THEN

 -- Debug message
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('- In Check_FK_Items before PROGRAM_TYPE_ID check : PROGRAM_TYPE_ID = ' || p_prgm_ptr_types_rec.PROGRAM_TYPE_ID);
 END IF;

   IF PVX_Utility_PVT.check_fk_exists(
         'PV_PARTNER_PROGRAM_TYPE_B',                          -- Parent schema object having the primary key
         'PROGRAM_TYPE_ID',                              -- Column name in the parent object that maps to the fk value
         p_prgm_ptr_types_rec.PROGRAM_TYPE_ID,           -- Value of fk to be validated against the parent object's pk column
         PVX_utility_PVT.g_number,                             -- datatype of fk
         NULL
   ) = FND_API.g_false
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_PRGM_PTR_TYPE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
 END IF;

  -- Debug message
  IF (PV_DEBUG_HIGH_ON) THEN

  PVX_UTILITY_PVT.debug_message('- In Check_FK_Items after PROGRAM_TYPE_ID FK check ');
  END IF;

END Check_FK_Items;




PROCEDURE Check_Lookup_Items(
      p_prgm_ptr_types_rec  IN  prgm_ptr_types_rec_type
     ,x_return_status       OUT NOCOPY VARCHAR2
     )

IS

BEGIN

    x_return_status := FND_API.g_ret_sts_success;

    -- Enter custom code here

END Check_Lookup_Items;




PROCEDURE Check_Items (
      p_prgm_ptr_types_rec   IN    prgm_ptr_types_rec_type
     ,p_validation_mode             IN    VARCHAR2
     ,x_return_status               OUT NOCOPY   VARCHAR2
     )

IS

     l_api_name    CONSTANT VARCHAR2(30) := ' Check_Items';
     l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_Req_Items call');
   END IF;

   -- Check Items Required/NOT NULL API calls
   Check_Req_Items(
        p_prgm_ptr_types_rec => p_prgm_ptr_types_rec
       ,p_validation_mode    => p_validation_mode
       ,x_return_status      => x_return_status
       );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_Req_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_UK_Items call');
   END IF;

    -- Check Items Uniqueness API calls
   Check_UK_Items(
        p_prgm_ptr_types_rec => p_prgm_ptr_types_rec
       ,p_validation_mode    => p_validation_mode
       ,x_return_status      => x_return_status
       );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_UK_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_FK_Items call');
   END IF;

   -- Check Items Foreign Keys API calls
   Check_FK_Items(
        p_prgm_ptr_types_rec => p_prgm_ptr_types_rec
       ,x_return_status      => x_return_status
       );

    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_FK_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_Lookup_Items call');
   END IF;

   -- Check Items Lookups
   Check_Lookup_Items(
       p_prgm_ptr_types_rec => p_prgm_ptr_types_rec
       ,x_return_status => x_return_status
       );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_Lookup_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Items;



PROCEDURE Complete_Rec (
     p_prgm_ptr_types_rec   IN  prgm_ptr_types_rec_type
    ,x_complete_rec         OUT NOCOPY prgm_ptr_types_rec_type
    )

IS

    CURSOR c_complete IS
       SELECT *
       FROM PV_PROGRAM_PARTNER_TYPES
       WHERE program_partner_types_id = p_prgm_ptr_types_rec.program_partner_types_id;

    l_prgm_ptr_types_rec c_complete%ROWTYPE;

BEGIN

    x_complete_rec := p_prgm_ptr_types_rec;


    OPEN c_complete;
    FETCH c_complete INTO l_prgm_ptr_types_rec;
    CLOSE c_complete;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Complete_Rec API prior to assigning program_id');
   END IF;

    -- program_partner_types_id
    IF p_prgm_ptr_types_rec.program_partner_types_id IS NULL THEN
       x_complete_rec.program_partner_types_id := l_prgm_ptr_types_rec.program_partner_types_id;
    END IF;

    -- PROGRAM_TYPE_ID
    IF p_prgm_ptr_types_rec.PROGRAM_TYPE_ID IS NULL THEN
       x_complete_rec.PROGRAM_TYPE_ID := l_prgm_ptr_types_rec.PROGRAM_TYPE_ID;
    END IF;

    -- partner_type
    IF p_prgm_ptr_types_rec.partner_type IS NULL THEN
       x_complete_rec.partner_type := l_prgm_ptr_types_rec.partner_type;
    END IF;

    -- last_update_date
    IF p_prgm_ptr_types_rec.last_update_date IS NULL THEN
       x_complete_rec.last_update_date := l_prgm_ptr_types_rec.last_update_date;
    END IF;

    -- last_updated_by
    IF p_prgm_ptr_types_rec.last_updated_by IS NULL THEN
       x_complete_rec.last_updated_by := l_prgm_ptr_types_rec.last_updated_by;
    END IF;

    -- creation_date
    IF p_prgm_ptr_types_rec.creation_date IS NULL THEN
       x_complete_rec.creation_date := l_prgm_ptr_types_rec.creation_date;
    END IF;

    -- created_by
    IF p_prgm_ptr_types_rec.created_by IS NULL THEN
       x_complete_rec.created_by := l_prgm_ptr_types_rec.created_by;
    END IF;

    -- last_update_login
    IF p_prgm_ptr_types_rec.last_update_login IS NULL THEN
       x_complete_rec.last_update_login := l_prgm_ptr_types_rec.last_update_login;
    END IF;

    -- object_version_number
    IF p_prgm_ptr_types_rec.object_version_number IS NULL THEN
       x_complete_rec.object_version_number := l_prgm_ptr_types_rec.object_version_number;
    END IF;

 END Complete_Rec;




PROCEDURE Validate_Prgm_Ptr_Type(
      p_api_version_number         IN   NUMBER
     ,p_init_msg_list              IN   VARCHAR2         := FND_API.G_FALSE
     ,p_validation_level           IN   NUMBER           := FND_API.G_VALID_LEVEL_FULL
     ,p_validation_mode            IN   VARCHAR2
     ,p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type
     ,x_return_status              OUT NOCOPY  VARCHAR2
     ,x_msg_count                  OUT NOCOPY  NUMBER
     ,x_msg_data                   OUT NOCOPY  VARCHAR2
     )

IS

l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_Prgm_Ptr_Type';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_object_version_number              NUMBER;
l_prgm_ptr_types_rec                 PV_PRGM_PTR_TYPES_PVT.prgm_ptr_types_rec_type;

BEGIN

       -- Standard Start of API savepoint
       SAVEPOINT VALIDATE_PGM_TGT_PTR_TYP_PVT;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

       -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('  Private API: ' || l_full_name || ' - start');
      END IF;

     IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
     -- Debug message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('  Private API: ' || l_full_name || ' - prior to Check_Items call');
     END IF;

              Check_Items(
                   p_prgm_ptr_types_rec  => p_prgm_ptr_types_rec
                  ,p_validation_mode     => p_validation_mode
                  ,x_return_status       => x_return_status
                  );

              -- Debug message
              IF (PV_DEBUG_HIGH_ON) THEN

              PVX_UTILITY_PVT.debug_message('  Private API: ' || l_full_name || ' - return status after Check_Items call ' || x_return_status);
              END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_Rec(
             p_api_version_number     => 1.0
            ,p_init_msg_list          => FND_API.G_FALSE
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
            ,p_prgm_ptr_types_rec     => l_prgm_ptr_types_rec
            );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO VALIDATE_PGM_TGT_PTR_TYP_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
              p_encoded => FND_API.G_FALSE
             ,p_count   => x_msg_count
             ,p_data    => x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO VALIDATE_PGM_TGT_PTR_TYP_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
              p_encoded => FND_API.G_FALSE
             ,p_count => x_msg_count
             ,p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO VALIDATE_PGM_TGT_PTR_TYP_PVT;
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
End Validate_Prgm_Ptr_Type;




PROCEDURE Validate_Rec(
      p_api_version_number         IN   NUMBER
     ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
     ,x_return_status              OUT NOCOPY  VARCHAR2
     ,x_msg_count                  OUT NOCOPY  NUMBER
     ,x_msg_data                   OUT NOCOPY  VARCHAR
     ,p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type
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
         ( p_count          =>   x_msg_count
          ,p_data           =>   x_msg_data
          );
END Validate_Rec;


END PV_PRGM_PTR_TYPES_PVT;

/
