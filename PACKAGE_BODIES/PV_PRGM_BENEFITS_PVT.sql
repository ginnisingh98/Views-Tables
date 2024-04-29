--------------------------------------------------------
--  DDL for Package Body PV_PRGM_BENEFITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRGM_BENEFITS_PVT" as
 /* $Header: pvxvppbb.pls 120.1 2006/07/25 17:49:51 dgottlie noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_BENEFITS_PVT
-- Purpose
--
-- History
--         28-FEB-2002    Jessica.Lee         Created
--          1-APR-2002    Peter.Nixon         Modified
--                        Changed benefit_id NUMBER to benefit_code VARCHAR2
--         24-SEP-2003    Karen.Tsao          Modified for 11.5.10
--         02-OCT-2003    Karen.Tsao          Update the Create_Prgm_Benefits, Update_Prgm_Benefits,
--                                            and Complete_Rec with three new column responsibility_id
--         06-NOV-2003    Karen.Tsao          Took out column responsibility_id
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME   CONSTANT VARCHAR2(30) := 'PV_PRGM_BENEFITS_PVT';
G_FILE_NAME  CONSTANT VARCHAR2(12) := 'pvxvpbsb.pls';


PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Prgm_Benefits(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_prgm_benefits_rec          IN   prgm_benefits_rec_type  := g_miss_prgm_benefits_rec
    ,x_program_benefits_id        OUT NOCOPY  NUMBER
    )

 IS
   l_api_version_number        CONSTANT  NUMBER                  := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30)            := 'Create_Prgm_Benefits';
   l_full_name                 CONSTANT  VARCHAR2(60)            := g_pkg_name ||'.'|| l_api_name;

   l_return_status                       VARCHAR2(1);
   l_prgm_benefits_rec                   prgm_benefits_rec_type  := p_prgm_benefits_rec;

   l_object_version_number               NUMBER                  := 1;
   l_uniqueness_check                    VARCHAR2(1);

   -- Cursor to get the sequence for pv_program_benefits_id
   CURSOR c_program_benefits_id_seq IS
      SELECT PV_PROGRAM_BENEFITS_S.NEXTVAL
      FROM dual;


   -- Cursor to validate the uniqueness
   CURSOR c_prgm_benefits_id_seq_exists (l_id IN NUMBER) IS
      SELECT  'X'
      FROM PV_PROGRAM_BENEFITS
      WHERE PROGRAM_BENEFITS_ID = l_id;

BEGIN
      ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Prgm_Benefits_PVT;

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

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_Utility_PVT.debug_message(l_full_name ||': validate');

      END IF;

      IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF l_prgm_benefits_rec.program_benefits_id IS NULL OR
        l_prgm_benefits_rec.program_benefits_id = FND_API.g_miss_num THEN
        LOOP
           -- Get the identifier
           OPEN c_program_benefits_id_seq;
           FETCH c_program_benefits_id_seq INTO l_prgm_benefits_rec.program_benefits_id;
           CLOSE c_program_benefits_id_seq;

           -- Check the uniqueness of the identifier
           OPEN c_prgm_benefits_id_seq_exists(l_prgm_benefits_rec.program_benefits_id);
           FETCH c_prgm_benefits_id_seq_exists INTO l_uniqueness_check;
           -- Exit when the identifier uniqueness is established
           EXIT WHEN c_prgm_benefits_id_seq_exists%ROWCOUNT = 0;
           CLOSE c_prgm_benefits_id_seq_exists;
        END LOOP;
      END IF;

      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - program_benefits_id = '|| l_prgm_benefits_rec.program_benefits_id);
      END IF;

      -- Populate the default required items
      l_prgm_benefits_rec.last_update_date      := SYSDATE;
      l_prgm_benefits_rec.last_updated_by       := FND_GLOBAL.user_id;
      l_prgm_benefits_rec.creation_date         := SYSDATE;
      l_prgm_benefits_rec.created_by            := FND_GLOBAL.user_id;
      l_prgm_benefits_rec.last_update_login     := FND_GLOBAL.conc_login_id;
      l_prgm_benefits_rec.object_version_number := l_object_version_number;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - Validate_Prgm_Benefits');
          END IF;


          -- Invoke validation procedures
          Validate_Prgm_Benefits(
             p_api_version_number     => 1.0
            ,p_init_msg_list          => FND_API.G_FALSE
            ,p_validation_level       => p_validation_level
            ,p_validation_mode        => JTF_PLSQL_API.g_create
            ,p_prgm_benefits_rec      => l_prgm_benefits_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
            );
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' -  Validate_Prgm_Benefits return_status = ' || x_return_status );
          END IF;

      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API:' || l_full_name || ' -  Calling create table handler');
      END IF;

      -- Invoke table handler(PV_PRGM_BENEFITS_PKG.Insert_Row)
      PV_PRGM_BENEFITS_PKG.Insert_Row(
           px_program_benefits_id    => l_prgm_benefits_rec.program_benefits_id
          ,p_program_id              => l_prgm_benefits_rec.program_id
          ,p_benefit_code            => l_prgm_benefits_rec.benefit_code
          ,p_benefit_id              => l_prgm_benefits_rec.benefit_id
          ,p_benefit_type_code       => l_prgm_benefits_rec.benefit_type_code
          ,p_delete_flag             => l_prgm_benefits_rec.delete_flag
          ,p_last_update_login       => l_prgm_benefits_rec.last_update_login
          ,p_object_version_number   => l_object_version_number
          ,p_last_update_date        => l_prgm_benefits_rec.last_update_date
          ,p_last_updated_by         => l_prgm_benefits_rec.last_updated_by
          ,p_created_by              => l_prgm_benefits_rec.created_by
          ,p_creation_date           => l_prgm_benefits_rec.creation_date
          );

      x_program_benefits_id := l_prgm_benefits_rec.program_benefits_id;

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
     ROLLBACK TO CREATE_PRGM_BENEFITS_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_PRGM_BENEFITS_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Prgm_Benefits_PVT;
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

END Create_Prgm_Benefits;


PROCEDURE Update_Prgm_Benefits(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_prgm_benefits_rec          IN   prgm_benefits_rec_type
    )

IS

CURSOR c_get_prgm_benefits(cv_program_benefits_id NUMBER) IS
    SELECT *
    FROM  PV_PROGRAM_BENEFITS
    WHERE PROGRAM_BENEFITS_ID = cv_program_benefits_id;

l_api_name                 CONSTANT VARCHAR2(30) := 'Update_Prgm_Benefits';
l_full_name                CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number       CONSTANT NUMBER       := 1.0;

-- Local Variables
l_ref_prgm_benefits_rec             c_get_Prgm_Benefits%ROWTYPE ;
l_tar_prgm_benefits_rec             PV_PRGM_BENEFITS_PVT.prgm_benefits_rec_type := p_prgm_benefits_rec;
l_rowid                             ROWID;

BEGIN
     ---------Initialize ------------------

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Prgm_Benefits_PVT;

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

      OPEN c_get_Prgm_Benefits( l_tar_prgm_benefits_rec.program_benefits_id);
      FETCH c_get_Prgm_Benefits INTO l_ref_prgm_benefits_rec  ;

       IF ( c_get_Prgm_Benefits%NOTFOUND) THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
         FND_MESSAGE.set_token('MODE','Update');
         FND_MESSAGE.set_token('ENTITY','Program_Benefits');
         FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_prgm_benefits_rec.program_benefits_id));
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: '||l_full_name||' - Close Cursor');
       END IF;
       CLOSE c_get_Prgm_Benefits;

      If (l_tar_prgm_benefits_rec.object_version_number is NULL or
          l_tar_prgm_benefits_rec.object_version_number = FND_API.G_MISS_NUM ) THEN

           FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
           FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
           FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Check Whether record has been changed by someone else
      IF (l_tar_prgm_benefits_rec.object_version_number <> l_ref_prgm_benefits_rec.object_version_number) THEN
           FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
           FND_MESSAGE.set_token('VALUE','PROGRAM_BENEFITS');
           FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API:  '||l_full_name||' - Validate_Prgm_Benefits');
          END IF;

          -- Invoke validation procedures
          Validate_Prgm_Benefits(
             p_api_version_number     => 1.0
            ,p_init_msg_list          => FND_API.G_FALSE
            ,p_validation_level       => p_validation_level
            ,p_validation_mode        => JTF_PLSQL_API.g_update
            ,p_prgm_benefits_rec      => p_prgm_benefits_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
            );
      END IF;

     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;

     -- replace g_miss_char/num/date with current column values
     Complete_Rec(
              p_prgm_benefits_rec => p_prgm_benefits_rec
             ,x_complete_rec      => l_tar_prgm_benefits_rec
             );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: '||l_full_name||' - Calling update table handler');
      END IF;

      -- Invoke table handler(PV_PRGM_BENEFITS_PKG.Update_Row)
      PV_PRGM_BENEFITS_PKG.Update_Row(
           p_program_benefits_id    => l_tar_prgm_benefits_rec.program_benefits_id
          ,p_program_id             => l_tar_prgm_benefits_rec.program_id
          ,p_benefit_code           => l_tar_prgm_benefits_rec.benefit_code
          ,p_benefit_id             => l_tar_prgm_benefits_rec.benefit_id
          ,p_benefit_type_code      => l_tar_prgm_benefits_rec.benefit_type_code
          ,p_delete_flag            => l_tar_prgm_benefits_rec.delete_flag
          ,p_last_update_login      => FND_GLOBAL.conc_login_id
          ,p_object_version_number  => l_tar_prgm_benefits_rec.object_version_number
          ,p_last_update_date       => SYSDATE
          ,p_last_updated_by        => FND_GLOBAL.user_id
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
     ROLLBACK TO UPDATE_Prgm_Benefits_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Prgm_Benefits_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Prgm_Benefits_PVT;
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

End Update_Prgm_Benefits;



PROCEDURE Delete_Prgm_Benefits(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_program_benefits_id        IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    )

IS

l_api_name                  CONSTANT  VARCHAR2(30) := 'Delete_Prgm_Benefits';
l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT  NUMBER       := 1.0;
l_object_version_number     NUMBER;

BEGIN

     ---- Initialize----------------

      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Prgm_Benefits_PVT;

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

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler...');
      END IF;

      -- Invoke table handler(PV_PRGM_BENEFITS_PKG.Delete_Row)
      PV_PRGM_BENEFITS_PKG.Delete_Row(
           p_program_benefits_id   => p_program_benefits_id
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
     ROLLBACK TO DELETE_Prgm_Benefits_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Prgm_Benefits_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Prgm_Benefits_PVT;
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

END Delete_Prgm_Benefits;



PROCEDURE Lock_Prgm_Benefits(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,px_program_benefits_id       IN   NUMBER
    ,p_object_version             IN   NUMBER
    )

IS

 l_api_name                CONSTANT VARCHAR2(30) := 'Lock_Prgm_Benefits';
 l_api_version_number      CONSTANT NUMBER       := 1.0;
 l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_program_benefits_id              NUMBER;

CURSOR c_Prgm_Benefits IS
   SELECT program_benefits_id
   FROM PV_PROGRAM_BENEFITS
   WHERE program_benefits_id = px_program_benefits_id
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || 'start');
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

  IF (PV_DEBUG_HIGH_ON) THEN



  PVX_UTILITY_PVT.debug_message(l_full_name||': start');

  END IF;
  OPEN c_Prgm_Benefits;

  FETCH c_Prgm_Benefits INTO l_program_benefits_id;

  IF (c_Prgm_Benefits%NOTFOUND) THEN
    CLOSE c_Prgm_Benefits;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Prgm_Benefits;

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
   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PVX_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
*/
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Prgm_Benefits_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Prgm_Benefits_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Prgm_Benefits_PVT;
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
END Lock_Prgm_Benefits;



PROCEDURE Check_UK_Items(
     p_prgm_benefits_rec          IN   prgm_benefits_rec_type
    ,p_validation_mode            IN   VARCHAR2   := JTF_PLSQL_API.g_create
    ,x_return_status              OUT NOCOPY  VARCHAR2
    )

IS

l_valid_flag  VARCHAR2(1);

BEGIN

      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN

         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'PV_PROGRAM_BENEFITS',
         'program_benefits_id = ''' || p_prgm_benefits_rec.program_benefits_id ||''''
         );

        IF l_valid_flag = FND_API.g_false THEN
          FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
          FND_MESSAGE.set_token('ID',to_char(p_prgm_benefits_rec.program_benefits_id) );
          FND_MESSAGE.set_token('ENTITY','PARTNER_BENEFITS');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
        END IF;
        -- Debug message
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('- In Check_UK_Items API' );
        END IF;
      END IF;

END Check_UK_Items;



PROCEDURE Check_Req_Items(
     p_prgm_benefits_rec    IN  prgm_benefits_rec_type
    ,p_validation_mode      IN  VARCHAR2    := JTF_PLSQL_API.g_create
    ,x_return_status	    OUT NOCOPY VARCHAR2
    )

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_prgm_benefits_rec.program_benefits_id = FND_API.g_miss_num
        OR p_prgm_benefits_rec.program_benefits_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_BENEFITS_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.program_id = FND_API.g_miss_num
        OR p_prgm_benefits_rec.program_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      /*
      IF p_prgm_benefits_rec.benefit_code = FND_API.g_miss_char
        OR p_prgm_benefits_rec.benefit_code IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','BENEFIT_CODE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      */

      IF p_prgm_benefits_rec.benefit_id = FND_API.g_miss_num
        OR p_prgm_benefits_rec.benefit_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','BENEFIT_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.benefit_type_code = FND_API.g_miss_char
        OR p_prgm_benefits_rec.benefit_type_code IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','BENEFIT_TYPE_CODE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.delete_flag = FND_API.g_miss_char
        OR p_prgm_benefits_rec.delete_flag IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','DELETE_FLAG');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.last_update_login = FND_API.g_miss_num
        OR p_prgm_benefits_rec.last_update_login IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATE_LOGIN');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.object_version_number = FND_API.g_miss_num
        OR p_prgm_benefits_rec.object_version_number IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.last_update_date = FND_API.g_miss_date
        OR p_prgm_benefits_rec.last_update_date IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATE_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.last_updated_by = FND_API.g_miss_num
        OR p_prgm_benefits_rec.last_updated_by IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATED_BY');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('- In Check_Req_Items API Before Created_by Check' );
      END IF;

      IF p_prgm_benefits_rec.created_by = FND_API.g_miss_num
        OR p_prgm_benefits_rec.created_by IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','CREATED_BY');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.creation_date = FND_API.g_miss_date
        OR p_prgm_benefits_rec.creation_date IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','CREATION_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE

      IF p_prgm_benefits_rec.program_benefits_id IS NULL THEN
	 FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_BENEFITS_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_prgm_benefits_rec.benefit_id = FND_API.g_miss_num
        OR p_prgm_benefits_rec.benefit_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','BENEFIT_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.benefit_type_code = FND_API.g_miss_char
        OR p_prgm_benefits_rec.benefit_type_code IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','BENEFIT_TYPE_CODE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.delete_flag = FND_API.g_miss_char
        OR p_prgm_benefits_rec.delete_flag IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','DELETE_FLAG');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_benefits_rec.object_version_number IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Req_Items;



PROCEDURE Check_FK_Items(
     p_prgm_benefits_rec IN  prgm_benefits_rec_type
    ,x_return_status     OUT NOCOPY VARCHAR2
    )
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

 ----------------------- PROGRAM_ID ------------------------
 IF (p_prgm_benefits_rec.PROGRAM_ID <> FND_API.g_miss_num
       AND p_prgm_benefits_rec.PROGRAM_ID IS NOT NULL ) THEN

 -- Debug message
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('- In Check_FK_Items : Before PROGRAM_ID fk check : PROGRAM_ID ' || p_prgm_benefits_rec.PROGRAM_ID);
 END IF;

   IF PVX_Utility_PVT.check_fk_exists(
         'PV_PARTNER_PROGRAM_B',                     -- Parent schema object having the primary key
         'PROGRAM_ID',                               -- Column name in the parent object that maps to the fk value
         p_prgm_benefits_rec.PROGRAM_ID,             -- Value of fk to be validated against the parent object's pk column
         PVX_utility_PVT.g_number,                   -- datatype of fk
         NULL
   ) = FND_API.g_false
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_PARTNER_PROGRAM');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
 END IF;

 -- Debug message
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('- In Check_FK_Items : After program_id fk check ');
 END IF;

END Check_FK_Items;



PROCEDURE Check_Lookup_Items(
     p_prgm_benefits_rec  IN  prgm_benefits_rec_type
    ,x_return_status      OUT NOCOPY VARCHAR2
    )

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   /*
   ----------------------- Benefit_Code lookup  ------------------------
   IF p_prgm_benefits_rec.Benefit_Code <> FND_API.g_miss_char  THEN

      IF PVX_Utility_PVT.check_lookup_exists(
            'FND_LOOKUP_VALUES',                       -- Look up Table Name
            'PV_PROGRAM_BENEFITS',                     -- Lookup Type
            p_prgm_benefits_rec.Benefit_Code           -- Lookup Code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_PROGRAM_BENEFIT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

      END IF;
   END IF;
   */

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Check_Lookup_Items :  x_return_status = '||x_return_status);
   END IF;

END Check_Lookup_Items;



PROCEDURE Check_Items (
     p_prgm_benefits_rec    IN    prgm_benefits_rec_type
    ,p_validation_mode      IN    VARCHAR2
    ,x_return_status        OUT NOCOPY   VARCHAR2
    )

IS

  l_api_name    CONSTANT VARCHAR2(30) := 'Check_Items';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_Req_Items call');
   END IF;

   -- Check Items Required/NOT NULL API calls
   Check_Req_Items(
       p_prgm_benefits_rec  => p_prgm_benefits_rec
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
       p_prgm_benefits_rec  => p_prgm_benefits_rec
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
       p_prgm_benefits_rec  => p_prgm_benefits_rec
      ,x_return_status      => x_return_status
      );

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
       p_prgm_benefits_rec  => p_prgm_benefits_rec
      ,x_return_status      => x_return_status
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
    p_prgm_benefits_rec  IN   prgm_benefits_rec_type
   ,x_complete_rec       OUT NOCOPY  prgm_benefits_rec_type
   )

IS

   CURSOR c_complete IS
      SELECT *
      FROM pv_program_benefits
      WHERE program_benefits_id = p_prgm_benefits_rec.program_benefits_id;

   l_prgm_benefits_rec c_complete%ROWTYPE;

BEGIN

   x_complete_rec := p_prgm_benefits_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_prgm_benefits_rec;
   CLOSE c_complete;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Complete_Rec API prior to assigning program_id');
   END IF;

   -- program_benefits_id
   -- IF p_prgm_benefits_rec.program_benefits_id = FND_API.g_miss_num THEN
   IF p_prgm_benefits_rec.program_benefits_id IS NULL THEN
      x_complete_rec.program_benefits_id := l_prgm_benefits_rec.program_benefits_id;
   END IF;

   -- program_id
   -- IF p_prgm_benefits_rec.program_id = FND_API.g_miss_num THEN
   IF p_prgm_benefits_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_prgm_benefits_rec.program_id;
   END IF;

   -- benefit_code
   -- IF p_prgm_benefits_rec.benefit_code = FND_API.g_miss_char THEN
   IF p_prgm_benefits_rec.benefit_code IS NULL THEN
      x_complete_rec.benefit_code := l_prgm_benefits_rec.benefit_code;
   END IF;

   -- benefit_id
   -- IF p_prgm_benefits_rec.benefit_id = FND_API.g_miss_num THEN
   IF p_prgm_benefits_rec.benefit_id IS NULL THEN
      x_complete_rec.benefit_id := l_prgm_benefits_rec.benefit_id;
   END IF;

   -- benefit_type_code
   -- IF p_prgm_benefits_rec.benefit_type_code = FND_API.g_miss_char THEN
   IF p_prgm_benefits_rec.benefit_type_code IS NULL THEN
      x_complete_rec.benefit_type_code := l_prgm_benefits_rec.benefit_type_code;
   END IF;

   -- delete_flag
   -- IF p_prgm_benefits_rec.delete_flag = FND_API.g_miss_char THEN
   IF p_prgm_benefits_rec.delete_flag IS NULL THEN
      x_complete_rec.delete_flag := l_prgm_benefits_rec.delete_flag;
   END IF;

  -- last_update_login
   -- IF p_prgm_benefits_rec.last_update_login = FND_API.g_miss_num THEN
   IF p_prgm_benefits_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_prgm_benefits_rec.last_update_login;
   END IF;

   -- object_version_number
   -- IF p_prgm_benefits_rec.object_version_number = FND_API.g_miss_num THEN
   IF p_prgm_benefits_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_prgm_benefits_rec.object_version_number;
   END IF;

   -- last_update_date
   -- IF p_prgm_benefits_rec.last_update_date = FND_API.g_miss_date THEN
   IF p_prgm_benefits_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_prgm_benefits_rec.last_update_date;
   END IF;

   -- last_updated_by
   -- IF p_prgm_benefits_rec.last_updated_by = FND_API.g_miss_num THEN
   IF p_prgm_benefits_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_prgm_benefits_rec.last_updated_by;
   END IF;

   -- created_by
   -- IF p_prgm_benefits_rec.created_by = FND_API.g_miss_num THEN
   IF p_prgm_benefits_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_prgm_benefits_rec.created_by;
   END IF;

   -- creation_date
   -- IF p_prgm_benefits_rec.creation_date = FND_API.g_miss_date THEN
   IF p_prgm_benefits_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_prgm_benefits_rec.creation_date;
   END IF;

END Complete_Rec;



PROCEDURE Validate_Prgm_Benefits(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_prgm_benefits_rec          IN   prgm_benefits_rec_type
    ,p_validation_mode            IN   VARCHAR2     	:= JTF_PLSQL_API.G_UPDATE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    )

IS

l_api_name                  CONSTANT  VARCHAR2(30)  := 'Validate_Prgm_Benefits';
l_full_name                 CONSTANT  VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT  NUMBER        := 1.0;
l_object_version_number               NUMBER;
l_prgm_benefits_rec                   PV_PRGM_BENEFITS_PVT.prgm_benefits_rec_type;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Validate_Prgm_Benefits_;

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
                  p_prgm_benefits_rec  => p_prgm_benefits_rec
                 ,p_validation_mode    => p_validation_mode
                 ,x_return_status      => x_return_status
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
           ,p_prgm_benefits_rec      => l_prgm_benefits_rec
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
     ROLLBACK TO Validate_Prgm_Benefits_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_Prgm_Benefits_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_Prgm_Benefits_;
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

End Validate_Prgm_Benefits;



PROCEDURE Validate_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_prgm_benefits_rec          IN   prgm_benefits_rec_type
    ,p_validation_mode            IN   VARCHAR2
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

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Rec;


END PV_PRGM_BENEFITS_PVT;

/
