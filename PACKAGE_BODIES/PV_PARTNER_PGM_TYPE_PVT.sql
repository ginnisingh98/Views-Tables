--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_PGM_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_PGM_TYPE_PVT" as
/* $Header: pvxvpptb.pls 115.7 2003/03/05 23:28:11 pukken ship $*/
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PARTNER_PGM_TYPE_PVT
-- Purpose
--
-- History
--         22-APR-2002    Peter.Nixon  Created
--         04-JUN-2002    Karen.Tsao   Added functions Can_Be_Inactive and Can_Be_Deleted
--         05-JUN-2002    Karen.Tsao   Modified the IF condition when populate enabled_flag and inactive_flag
--         11-JUN-2002    Karen.Tsao   Modified to reverse logic of G_MISS_XXX and NULL.
--         05-MAR-2003    pukken       Modified Can_Be_Inactive function to include ARCHIVE status also
--
--
--
--
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_PARTNER_PGM_TYPE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvpptb.pls';

/***  private routine declaration ***/
PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION Can_Be_Inactive (
   p_program_type_id          NUMBER
)
RETURN BOOLEAN;

FUNCTION Can_Be_Deleted (
   p_program_type_id          NUMBER
)
RETURN BOOLEAN;


PROCEDURE Create_Partner_Pgm_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_ptr_prgm_type_rec          IN   ptr_prgm_type_rec_type  := g_miss_ptr_prgm_type_rec
    ,x_PROGRAM_TYPE_ID      OUT NOCOPY  NUMBER
     )

 IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'Create_Partner_Pgm_Type';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name || '.'|| L_API_NAME;

   l_return_status                       VARCHAR2(1);
   l_ptr_prgm_type_rec                   ptr_prgm_type_rec_type := p_ptr_prgm_type_rec ;

   l_object_version_number               NUMBER                 := 1;
   l_uniqueness_check                    VARCHAR2(1);

   -- Cursor to get the sequence for pv_partner_program_type_b
   CURSOR c_partner_prgm_type_id_seq IS
      SELECT PV_PARTNER_PROGRAM_TYPE_B_S.NEXTVAL
      FROM dual;

   -- Cursor to validate the uniqueness
   CURSOR c_ptr_prgm_type_id_seq_exists (l_id IN NUMBER) IS
      SELECT 'X'
      FROM PV_PARTNER_PROGRAM_TYPE_B
      WHERE PROGRAM_TYPE_ID = l_id;

BEGIN
      ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Partner_Pgm_Type_PVT;

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


   IF p_ptr_prgm_type_rec.PROGRAM_TYPE_ID IS NULL
     OR l_ptr_prgm_type_rec.PROGRAM_TYPE_ID = FND_API.g_miss_num THEN
     LOOP
         -- Get the identifier
         OPEN c_partner_prgm_type_id_seq;
         FETCH c_partner_prgm_type_id_seq INTO l_ptr_prgm_type_rec.PROGRAM_TYPE_ID;
         CLOSE c_partner_prgm_type_id_seq;

         -- Check the uniqueness of the identifier
         OPEN c_ptr_prgm_type_id_seq_exists(l_ptr_prgm_type_rec.PROGRAM_TYPE_ID);
         FETCH c_ptr_prgm_type_id_seq_exists INTO l_uniqueness_check;
         -- Exit when the identifier uniqueness is established
           EXIT WHEN c_ptr_prgm_type_id_seq_exists%ROWCOUNT = 0;
         CLOSE c_ptr_prgm_type_id_seq_exists;
      END LOOP;
   END IF;

      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - PROGRAM_TYPE_ID = '|| l_ptr_prgm_type_rec.PROGRAM_TYPE_ID);
      END IF;

   IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API ' || l_full_name || ' - Validate_Partner_Pgm_Type');
          END IF;

          -- Populate the default required items
          l_ptr_prgm_type_rec.last_update_date      := SYSDATE;
          l_ptr_prgm_type_rec.last_updated_by       := FND_GLOBAL.user_id;
          l_ptr_prgm_type_rec.creation_date         := SYSDATE;
          l_ptr_prgm_type_rec.created_by            := FND_GLOBAL.user_id;
          l_ptr_prgm_type_rec.last_update_login     := FND_GLOBAL.conc_login_id;
          l_ptr_prgm_type_rec.object_version_number := l_object_version_number;

          -- populate enabled_flag only if value not passed from application
           IF l_ptr_prgm_type_rec.enabled_flag = FND_API.g_miss_char
             OR l_ptr_prgm_type_rec.enabled_flag IS NULL THEN
             l_ptr_prgm_type_rec.enabled_flag        := 'Y';
           END IF;

          -- populate active_flag only if value not passed from application
           IF l_ptr_prgm_type_rec.active_flag = FND_API.g_miss_char
             OR l_ptr_prgm_type_rec.active_flag IS NULL THEN
             l_ptr_prgm_type_rec.active_flag        := 'Y';
           END IF;

          -- Invoke validation procedures
          Validate_partner_pgm_type(
             p_api_version_number  => 1.0
            ,p_init_msg_list       => FND_API.G_FALSE
            ,p_validation_level    => p_validation_level
            ,p_validation_mode     => JTF_PLSQL_API.g_create
            ,p_ptr_prgm_type_rec   => l_ptr_prgm_type_rec
            ,x_return_status       => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
            );
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' -  Validate_Partner_Program return_status = ' || x_return_status );
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

      -- Invoke table handler(PV_PARTNER_PGM_TYPE_PKG.Insert_Row)
      PV_PARTNER_PGM_TYPE_PKG.Insert_Row(
           px_PROGRAM_TYPE_ID   => l_ptr_prgm_type_rec.PROGRAM_TYPE_ID
          ,p_active_flag              => l_ptr_prgm_type_rec.active_flag
          ,p_enabled_flag             => l_ptr_prgm_type_rec.enabled_flag
          ,p_object_version_number    => l_object_version_number
          ,p_creation_date            => l_ptr_prgm_type_rec.creation_date
          ,p_created_by               => l_ptr_prgm_type_rec.created_by
          ,p_last_update_date         => l_ptr_prgm_type_rec.last_update_date
          ,p_last_updated_by          => l_ptr_prgm_type_rec.last_updated_by
          ,p_last_update_login        => l_ptr_prgm_type_rec.last_update_login
          ,p_program_type_name        => l_ptr_prgm_type_rec.program_type_name
          ,p_program_type_description => l_ptr_prgm_type_rec.program_type_description
          );

          x_PROGRAM_TYPE_ID := l_ptr_prgm_type_rec.PROGRAM_TYPE_ID;

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
     ROLLBACK TO CREATE_Partner_Pgm_Type_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF (PV_DEBUG_HIGH_ON) THEN



     PVX_UTILITY_PVT.debug_message('In CREATE_PARTNER_PROGRAM API ERROR BLOCK');

     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Partner_Pgm_Type_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Partner_Pgm_Type_PVT;
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

End Create_Partner_Pgm_Type;


PROCEDURE Update_Partner_Pgm_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_ptr_prgm_type_rec          IN   ptr_prgm_type_rec_type
    )

 IS

CURSOR c_get_partner_pgm_type(cv_PROGRAM_TYPE_ID NUMBER) IS
    SELECT *
    FROM  PV_PARTNER_PROGRAM_TYPE_B
    WHERE PROGRAM_TYPE_ID = cv_PROGRAM_TYPE_ID;

l_api_name                   CONSTANT VARCHAR2(30) := 'Update_Partner_Pgm_Type';
l_full_name                  CONSTANT VARCHAR2(60) := g_pkg_name || '.'|| L_API_NAME;
l_api_version_number         CONSTANT NUMBER       := 1.0;

-- Local Variables
l_ref_ptr_prgm_type_rec      c_get_Partner_Pgm_Type%ROWTYPE ;
l_tar_ptr_prgm_type_rec      PV_PARTNER_PGM_TYPE_PVT.ptr_prgm_type_rec_type := p_ptr_prgm_type_rec;

 BEGIN
     ---------Initialize ------------------

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Partner_Pgm_Type_PVT;

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

      OPEN c_get_Partner_Pgm_Type(l_tar_ptr_prgm_type_rec.PROGRAM_TYPE_ID);
      FETCH c_get_Partner_Pgm_Type INTO l_ref_ptr_prgm_type_rec ;

        IF (c_get_Partner_Pgm_Type%NOTFOUND) THEN
           FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
           FND_MESSAGE.set_token('MODE','Update');
           FND_MESSAGE.set_token('ENTITY','Partner_Pgm_Type');
           FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_ptr_prgm_type_rec.PROGRAM_TYPE_ID));
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

      CLOSE     c_get_Partner_Pgm_Type;

      IF (l_tar_ptr_prgm_type_rec.object_version_number IS NULL OR
          l_tar_ptr_prgm_type_rec.object_version_number = FND_API.G_MISS_NUM ) THEN

           FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ID');
           FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
           FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_ptr_prgm_type_rec.object_version_number <> l_ref_ptr_prgm_type_rec.object_version_number) THEN
           FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
           FND_MESSAGE.set_token('VALUE','ptr_prgm_type');
           FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: '||l_full_name||' - Validate_Partner_Pgm_Type');
          END IF;


          -- Invoke validation procedures
          Validate_partner_pgm_type(
             p_api_version_number       => 1.0
            ,p_init_msg_list            => FND_API.G_FALSE
            ,p_validation_level         => p_validation_level
            ,p_validation_mode 		=> JTF_PLSQL_API.g_update
            ,p_ptr_prgm_type_rec        => p_ptr_prgm_type_rec
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data
            );
      END IF;

     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;

     IF (PV_DEBUG_HIGH_ON) THEN



     PVX_Utility_PVT.debug_message('active_flag = '|| l_tar_ptr_prgm_type_rec.active_flag);

     END IF;
     -- Check whether this program type can be inactive
     IF (l_tar_ptr_prgm_type_rec.active_flag <> FND_API.g_miss_char and
         l_tar_ptr_prgm_type_rec.active_flag = 'N' and
         l_tar_ptr_prgm_type_rec.active_flag <> l_ref_ptr_prgm_type_rec.active_flag) THEN
        IF NOT Can_Be_Inactive(l_tar_ptr_prgm_type_rec.program_type_id) THEN
           FND_MESSAGE.set_name('PV', 'PV_PRGM_TYPE_CAN_NOT_INACTIVE');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

     -- replace g_miss_char/num/date with current column values
     Complete_Rec(
              p_ptr_prgm_type_rec => p_ptr_prgm_type_rec
             ,x_complete_rec      => l_tar_ptr_prgm_type_rec
             );

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling update table handler');
     END IF;

     -- Invoke table handler(PV_PARTNER_PGM_TYPE_PKG.Update_Row)
     PV_PARTNER_PGM_TYPE_PKG.Update_Row(
           p_PROGRAM_TYPE_ID    => l_tar_ptr_prgm_type_rec.PROGRAM_TYPE_ID
          ,p_active_flag              => l_tar_ptr_prgm_type_rec.active_flag
          ,p_enabled_flag             => l_tar_ptr_prgm_type_rec.enabled_flag
          ,p_object_version_number    => l_tar_ptr_prgm_type_rec.object_version_number
          ,p_last_update_date         => SYSDATE
          ,p_last_updated_by          => FND_GLOBAL.user_id
          ,p_last_update_login        => FND_GLOBAL.conc_login_id
          ,p_program_type_name        => l_tar_ptr_prgm_type_rec.program_type_name
          ,p_program_type_description => l_tar_ptr_prgm_type_rec.program_type_description
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
     ROLLBACK TO UPDATE_Partner_Pgm_Type_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Partner_Pgm_Type_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Partner_Pgm_Type_PVT;
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

End Update_Partner_Pgm_Type;



PROCEDURE Delete_Partner_Pgm_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_PROGRAM_TYPE_ID      IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    )

 IS

 CURSOR c_get_ptr_prgm_type_rec(cv_PROGRAM_TYPE_ID NUMBER) IS
    SELECT *
    FROM  PV_PARTNER_PROGRAM_TYPE_B
    WHERE PROGRAM_TYPE_ID = cv_PROGRAM_TYPE_ID;

l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Partner_Pgm_Type';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;

l_tar_ptr_prgm_type_rec              PV_PARTNER_PGM_TYPE_PVT.ptr_prgm_type_rec_type;
l_ref_ptr_prgm_type_rec              c_get_ptr_prgm_type_rec%ROWTYPE;
l_PROGRAM_TYPE_ID              NUMBER;
l_return_status                      VARCHAR2(1);
l_msg_count                          NUMBER;
l_msg_data                           VARCHAR2(2000);
l_object_version_number              NUMBER;
l_index                              NUMBER;

BEGIN
     ---------Initialize ------------------

      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Partner_Pgm_Type_PVT;

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

     PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - checking for object_version_number = ' || p_object_version_number);
     END IF;
     IF (p_object_version_number is NULL or
          p_object_version_number = FND_API.G_MISS_NUM ) THEN

           FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
           FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
           FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- set values in record
      l_tar_ptr_prgm_type_rec.PROGRAM_TYPE_ID       := p_PROGRAM_TYPE_ID;
      l_tar_ptr_prgm_type_rec.enabled_flag                := 'N';
      l_tar_ptr_prgm_type_rec.object_version_number       := p_object_version_number;

      -- get record to be soft-deleted
      OPEN c_get_ptr_prgm_type_rec(p_PROGRAM_TYPE_ID);
      FETCH c_get_ptr_prgm_type_rec INTO l_ref_ptr_prgm_type_rec  ;

      IF ( c_get_ptr_prgm_type_rec%NOTFOUND) THEN
       FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
       FND_MESSAGE.set_token('MODE','Update');
       FND_MESSAGE.set_token('ENTITY','Partner_Program_Type');
       FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_ptr_prgm_type_rec.PROGRAM_TYPE_ID));
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
      END IF;

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('Private API: '|| l_full_name || ' - Close Cursor');
     END IF;
     CLOSE     c_get_ptr_prgm_type_rec;

     IF (l_tar_ptr_prgm_type_rec.object_version_number is NULL or
          l_tar_ptr_prgm_type_rec.object_version_number = FND_API.G_MISS_NUM ) THEN

           FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
           FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
           FND_MSG_PUB.add;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_ptr_prgm_type_rec.object_version_number <> l_ref_ptr_prgm_type_rec.object_version_number) THEN
           FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
           FND_MESSAGE.set_token('VALUE','Partner_Program_Type');
           FND_MSG_PUB.add;
          raise FND_API.G_EXC_ERROR;
      End if;

     -- Check whether this program type can be deleted
     IF NOT Can_Be_Deleted(p_PROGRAM_TYPE_ID) THEN
        FND_MESSAGE.set_name('PV', 'PV_PRGM_TYPE_CAN_NOT_DELETE');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

       -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling update for soft delete');
     END IF;

     -- Invoke table handler(PV_PARTNER_PGM_TYPE_PVT.Update_Partner_Pgm_Type)
      PV_PARTNER_PGM_TYPE_PVT.Update_Partner_Pgm_Type(
           p_api_version_number         => l_api_version_number
          ,p_init_msg_list              => FND_API.g_false
          ,p_commit                     => FND_API.g_false
          ,p_validation_level           => FND_API.g_valid_level_full
          ,x_return_status              => l_return_status
          ,x_msg_count                  => l_msg_count
          ,x_msg_data                   => l_msg_data
          ,p_ptr_prgm_type_rec          => l_tar_ptr_prgm_type_rec
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
     ROLLBACK TO DELETE_Partner_Pgm_Type_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Partner_Pgm_Type_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Partner_Pgm_Type_PVT;
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
End Delete_Partner_Pgm_Type;




PROCEDURE Lock_Partner_Pgm_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,px_PROGRAM_TYPE_ID     IN  NUMBER
    ,p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Partner_Pgm_Type';
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name || '.'|| L_API_NAME;
L_API_VERSION_NUMBER        CONSTANT NUMBER       := 1.0;
l_PROGRAM_TYPE_ID              NUMBER;

CURSOR c_Partner_Pgm_Type IS
   SELECT PROGRAM_TYPE_ID
   FROM PV_PARTNER_PROGRAM_TYPE_B
   WHERE PROGRAM_TYPE_ID = px_PROGRAM_TYPE_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number
                                         ,p_api_version_number
                                         ,l_api_name
                                         ,G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------
  OPEN c_Partner_Pgm_Type;

  FETCH c_Partner_Pgm_Type INTO l_PROGRAM_TYPE_ID;

  IF (c_Partner_Pgm_Type%NOTFOUND) THEN
    CLOSE c_Partner_Pgm_Type;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Partner_Pgm_Type;

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
     ROLLBACK TO LOCK_Partner_Pgm_Type_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Partner_Pgm_Type_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Partner_Pgm_Type_PVT;
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
End Lock_Partner_Pgm_Type;



PROCEDURE Check_UK_Items(
     p_ptr_prgm_type_rec     IN  ptr_prgm_type_rec_type
    ,p_validation_mode       IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status         OUT NOCOPY VARCHAR2
    )
IS

l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN

         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'PV_PARTNER_PROGRAM_TYPE_B',
         'PROGRAM_TYPE_ID = ''' || p_ptr_prgm_type_rec.PROGRAM_TYPE_ID ||''''
         );
      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('- In Check_UK_Items API after PROGRAM_TYPE_ID check' );
      END IF;

        IF l_valid_flag = FND_API.g_false THEN
           FND_MESSAGE.set_name('PVX', 'PV_API_DUPLICATE_ENTITY');
           FND_MESSAGE.set_token('ID',to_char( p_ptr_prgm_type_rec.PROGRAM_TYPE_ID) );
           FND_MESSAGE.set_token('ENTITY','ptr_prgm_type');
           FND_MSG_PUB.add;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
        END IF;
      END IF;

END Check_UK_Items;



PROCEDURE Check_Req_Items(
     p_ptr_prgm_type_rec      IN  ptr_prgm_type_rec_type
    ,p_validation_mode        IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status	      OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_ptr_prgm_type_rec.PROGRAM_TYPE_ID = FND_API.g_miss_num
         OR p_ptr_prgm_type_rec.PROGRAM_TYPE_ID IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_TYPE_ID');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;


      IF p_ptr_prgm_type_rec.active_flag = FND_API.g_miss_char
         OR p_ptr_prgm_type_rec.active_flag IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','ACTIVE_FLAG');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;


      IF p_ptr_prgm_type_rec.enabled_flag = FND_API.g_miss_char
         OR p_ptr_prgm_type_rec.enabled_flag IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','ENABLED_FLAG');
           FND_MSG_PUB.add;
           x_return_status := FND_API.g_ret_sts_error;
           RETURN;
      END IF;


      IF p_ptr_prgm_type_rec.program_type_name = FND_API.g_miss_char
         OR p_ptr_prgm_type_rec.program_type_name IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_TYPE_NAME');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;


      IF p_ptr_prgm_type_rec.object_version_number = FND_API.g_miss_num
       OR p_ptr_prgm_type_rec.object_version_number IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_type_rec.creation_date = FND_API.g_miss_date
       OR p_ptr_prgm_type_rec.creation_date IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','CREATION_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('- In Check_Req_Items API Before Created_by Check' );
      END IF;


      IF p_ptr_prgm_type_rec.created_by = FND_API.g_miss_num
       OR p_ptr_prgm_type_rec.created_by IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','CREATED_BY');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_type_rec.last_update_date = FND_API.g_miss_date
      OR p_ptr_prgm_type_rec.last_update_date IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATE_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_type_rec.last_updated_by = FND_API.g_miss_num
       OR p_ptr_prgm_type_rec.last_updated_by IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATED_BY');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_type_rec.last_update_login = FND_API.g_miss_num
       OR p_ptr_prgm_type_rec.last_update_login IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATE_LOGIN');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_ptr_prgm_type_rec.PROGRAM_TYPE_ID IS NULL THEN
	 Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_TYPE_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_type_rec.object_version_number IS NULL THEN
	 Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Req_Items;



PROCEDURE Check_FK_Items(
     p_ptr_prgm_type_rec  IN   ptr_prgm_type_rec_type
    ,x_return_status      OUT NOCOPY  VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- There are no FK relationships to check
   -- Enter custom code here

END Check_FK_Items;



PROCEDURE Check_Lookup_Items(
     p_ptr_prgm_type_rec  IN   ptr_prgm_type_rec_type
    ,x_return_status      OUT NOCOPY  VARCHAR2
    )

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- There are no Lookup Items to check
   -- Enter custom code here

END Check_Lookup_Items;



PROCEDURE Check_Items (
     p_ptr_prgm_type_rec   IN    ptr_prgm_type_rec_type
    ,p_validation_mode     IN    VARCHAR2
    ,x_return_status       OUT NOCOPY   VARCHAR2
    )

IS

BEGIN

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_Req_Items call');
   END IF;

   -- Check Items Required/NOT NULL API calls
   Check_Req_Items(
       p_ptr_prgm_type_rec  => p_ptr_prgm_type_rec
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
       p_ptr_prgm_type_rec  => p_ptr_prgm_type_rec
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
       p_ptr_prgm_type_rec  => p_ptr_prgm_type_rec
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
       p_ptr_prgm_type_rec  => p_ptr_prgm_type_rec
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
       p_ptr_prgm_type_rec  IN  ptr_prgm_type_rec_type
      ,x_complete_rec       OUT NOCOPY ptr_prgm_type_rec_type
      )
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM PV_PARTNER_PROGRAM_TYPE_VL
      WHERE PROGRAM_TYPE_ID = p_ptr_prgm_type_rec.PROGRAM_TYPE_ID;

   l_ptr_prgm_type_rec c_complete%ROWTYPE;

BEGIN
   x_complete_rec := p_ptr_prgm_type_rec;

   OPEN c_complete;
   FETCH c_complete INTO l_ptr_prgm_type_rec;
   CLOSE c_complete;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Complete_Rec API prior to assigning PROGRAM_TYPE_ID');
   END IF;

   -- PROGRAM_TYPE_ID
   --IF p_ptr_prgm_type_rec.PROGRAM_TYPE_ID = FND_API.g_miss_num THEN
   IF p_ptr_prgm_type_rec.PROGRAM_TYPE_ID IS NULL THEN
      x_complete_rec.PROGRAM_TYPE_ID := l_ptr_prgm_type_rec.PROGRAM_TYPE_ID;
   END IF;

   -- active_flag
   --IF p_ptr_prgm_type_rec.active_flag = FND_API.g_miss_char THEN
   IF p_ptr_prgm_type_rec.active_flag IS NULL THEN
      x_complete_rec.active_flag := l_ptr_prgm_type_rec.active_flag;
   END IF;

   -- enabled_flag
   --IF p_ptr_prgm_type_rec.enabled_flag = FND_API.g_miss_char THEN
   IF p_ptr_prgm_type_rec.enabled_flag IS NULL THEN
     x_complete_rec.enabled_flag := l_ptr_prgm_type_rec.enabled_flag;
   END IF;

   -- program_type_name
   --IF p_ptr_prgm_type_rec.program_type_name = FND_API.g_miss_char THEN
   IF p_ptr_prgm_type_rec.program_type_name IS NULL THEN
      x_complete_rec.program_type_name := l_ptr_prgm_type_rec.program_type_name;
   END IF;

   -- program_type_description
   --IF p_ptr_prgm_type_rec.program_type_description = FND_API.g_miss_char THEN
   IF p_ptr_prgm_type_rec.program_type_description IS NULL THEN
      x_complete_rec.program_type_description := l_ptr_prgm_type_rec.program_type_description;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Complete_Rec API prior to assigning object_version_number');
   END IF;

   -- object_version_number
   --IF p_ptr_prgm_type_rec.object_version_number = FND_API.g_miss_num THEN
   IF p_ptr_prgm_type_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_ptr_prgm_type_rec.object_version_number;
   END IF;

   -- creation_date
   --IF p_ptr_prgm_type_rec.creation_date = FND_API.g_miss_date THEN
   IF p_ptr_prgm_type_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_ptr_prgm_type_rec.creation_date;
   END IF;

   -- created_by
   --IF p_ptr_prgm_type_rec.created_by = FND_API.g_miss_num THEN
   IF p_ptr_prgm_type_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_ptr_prgm_type_rec.created_by;
   END IF;

   -- last_update_date
   --IF p_ptr_prgm_type_rec.last_update_date = FND_API.g_miss_date THEN
   IF p_ptr_prgm_type_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_ptr_prgm_type_rec.last_update_date;
   END IF;

   -- last_updated_by
   --IF p_ptr_prgm_type_rec.last_updated_by = FND_API.g_miss_num THEN
   IF p_ptr_prgm_type_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_ptr_prgm_type_rec.last_updated_by;
   END IF;

   -- last_update_login
   --IF p_ptr_prgm_type_rec.last_update_login = FND_API.g_miss_num THEN
   IF p_ptr_prgm_type_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_ptr_prgm_type_rec.last_update_login;
   END IF;

END Complete_Rec;


PROCEDURE Validate_partner_pgm_type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2         := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER           := FND_API.G_VALID_LEVEL_FULL
    ,p_ptr_prgm_type_rec          IN   ptr_prgm_type_rec_type
    ,p_validation_mode            IN   VARCHAR2     	:= Jtf_Plsql_Api.G_UPDATE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    )

 IS

l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_Partner_Pgm_Type';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name || '.'|| L_API_NAME;
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_object_version_number              NUMBER;
l_ptr_prgm_type_rec                  PV_Partner_Pgm_Type_PVT.ptr_prgm_type_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Partner_Pgm_Type_;

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
                  p_ptr_prgm_type_rec => p_ptr_prgm_type_rec
                 ,p_validation_mode   => p_validation_mode
                 ,x_return_status     => x_return_status
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
           ,p_ptr_prgm_type_rec      => l_ptr_prgm_type_rec
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
     ROLLBACK TO VALIDATE_Partner_Pgm_Type_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Partner_Pgm_Type_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Partner_Pgm_Type_;
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

END Validate_Partner_Pgm_Type;


PROCEDURE Validate_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_ptr_prgm_type_rec          IN   ptr_prgm_type_rec_type
    ,p_validation_mode            IN   VARCHAR2     := Jtf_Plsql_Api.G_UPDATE
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
      FND_MSG_PUB.Count_And_Get(
          p_count          =>   x_msg_count
         ,p_data           =>   x_msg_data
         );

END Validate_Rec;


/***
 * Private Function  Check_Can_Be_Inactive
 * Provide the logic for checking if the Partner Program Type can be inactive
 ****/
FUNCTION Can_Be_Inactive (
   p_program_type_id          NUMBER
)
RETURN BOOLEAN
IS
   l_inactive             BOOLEAN := TRUE;
   l_exists             VARCHAR2(1);

   CURSOR partner_program_cur(l_program_type_id in number) is
      SELECT 'x' FROM DUAL WHERE EXISTS (
         SELECT 'x' FROM PV_PARTNER_PROGRAM_B
         WHERE PROGRAM_TYPE_ID = l_program_type_id
         AND PROGRAM_STATUS_CODE NOT IN ('CANCEL', 'CLOSED','ARCHIVE')
         AND ENABLED_FLAG = 'Y'
      );

BEGIN
   OPEN partner_program_cur(p_program_type_id);
   FETCH partner_program_cur into l_exists;

   -- If there is at least one record exists, this program type cannot be inactive
   IF partner_program_cur%FOUND THEN
      l_inactive := false;
   END IF;
   CLOSE partner_program_cur;
   return l_inactive;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Can_Be_Inactive;



/***
 * Private Function  Check_Can_Be_Deleted
 * Provide the logic for checking if the Partner Program Type can be deleted
 ****/
FUNCTION Can_Be_Deleted (
   p_program_type_id          NUMBER
)
RETURN BOOLEAN
IS
   l_delete             BOOLEAN := TRUE;
   l_exists             VARCHAR2(1);

   CURSOR partner_program_cur(l_program_type_id in number) is
      SELECT 'x' FROM DUAL WHERE EXISTS (
         SELECT 'x' FROM PV_PARTNER_PROGRAM_B
         WHERE PROGRAM_TYPE_ID = l_program_type_id
         AND ENABLED_FLAG = 'Y'
      );

BEGIN
   OPEN partner_program_cur(p_program_type_id);
   FETCH partner_program_cur into l_exists;

   -- If there is at least one record exists, this program type cannot be deleted
   IF partner_program_cur%FOUND THEN
      l_delete := false;
   END IF;
   CLOSE partner_program_cur;
   return l_delete;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Can_Be_Deleted;


END PV_Partner_Pgm_Type_PVT;

/
