--------------------------------------------------------
--  DDL for Package Body PV_PRGM_CONTRACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRGM_CONTRACTS_PVT" AS
 /* $Header: pvxvppcb.pls 120.2 2005/09/13 10:44:12 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_CONTRACTS_PVT
-- Purpose
--
-- History
--         7-MAR-2002    Peter.Nixon    Created
--        30-APR-2002    Peter.Nixon    Modified
--        04-JUN-2002    Karen.Tsao     Modified
--                                      Uncomment the CONTRACT_ID checking in Check_FK_Items
--        10-JUN-2002    Karen.Tsao     Modified the token of error message of duplicate GEO_HIERARCHY_ID
--                                      in Check_Uk_Items. Passed Geo_Area_Name instead of program_contracts_id.
--        11-JUN-2002    Karen.Tsao     Modified to reverse logic of G_MISS_XXX and NULL.
--        10-SEP-2002    Karen.Tsao     Modified to Create_Prgm_Contracts, Update_Prgm_Contracts,
--                                      Complete_Rec, and Check_UK_Items for new column DEFAULT_CONTRACT_FLAG.
--        13-SEP-2002    Karen.Tsao     Added Delete_Default_Prgm_Contracts procedure.
--        27-NOV-2002    Karen.Tsao     1. Debug message to be wrapped with IF check.
--                                      2. Replace of COPY with NOCOPY string.
--        10-DEC-2002    Karen.Tsao     1. Use <> instead of !=
--                                      2. Added line "WHENEVER OSERROR EXIT FAILURE ROLLBACK;"
--        01-JUL-2003    Karen.Tsao     Made modification to accommodate deleteing default_contract_flag column.
--        23-JUL-2003    Karen.Tsao     Added Terminate_Contract API.
--        28-AUG-2003    Karen.Tsao     Change membership_type to member_type_code.
--        24-OCT-2003    Karen.Tsao     Passed Fnd_Api.G_FALSE to p_init_msg_list in Terminate_Contract.
--        11-NOV-2003    Karen.Tsao     Modified Terminate_Contract:
--                                      1. Took out the "ROLLBACK TO CREATE_PRGM_CONTRACTS_PVT;" which is wrong.
--                                      2. Assigned OKC_API.G_MISS_XXX to l_in_kolchrv_rec.
--        13-DEC-2004    Karen.Tsao     language_code column is added for R12.
--        26-MAY-2005    Karen.Tsao     Remove language_code column and related changes.
--        06-SEP-2005    Karen.Tsao     Modified Check_FK_Items to check against OKC_TERMS_TEMPLATES_ALL.
--        13-SEP-2005    Karen.Tsao     Removed Terminate_Contract API.
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30)  := 'PV_PRGM_CONTRACTS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvppcb.pls';


PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Prgm_Contracts(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_prgm_contracts_rec         IN   prgm_contracts_rec_type  := g_miss_prgm_contracts_rec
    ,x_program_contracts_id       OUT NOCOPY  NUMBER
    )

 IS
   l_api_version_number        CONSTANT  NUMBER                   := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30)             := 'Create_Prgm_Contracts';
   l_full_name                 CONSTANT  VARCHAR2(60)             := g_pkg_name ||'.'|| l_api_name;

   l_return_status                       VARCHAR2(1);
   l_prgm_contracts_rec                  prgm_contracts_rec_type  := p_prgm_contracts_rec;

   l_object_version_number               NUMBER                   := 1;
   l_uniqueness_check                    VARCHAR2(1);

   -- Cursor to get the sequence for pv_program_contracts_id
   CURSOR c_prgm_contracts_id_seq IS
       SELECT PV_PROGRAM_CONTRACTS_S.NEXTVAL
        FROM dual;


   -- Cursor to validate the uniqueness
   CURSOR c_prgm_cntrcts_id_seq_exists (l_id IN NUMBER) IS
      SELECT  'X'
      FROM PV_PROGRAM_CONTRACTS
      WHERE program_contracts_id = l_id;

BEGIN
      ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT Create_Prgm_Contracts_PVT;

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


   IF l_prgm_contracts_rec.program_contracts_id IS NULL OR
      l_prgm_contracts_rec.program_contracts_id = FND_API.g_miss_num THEN
      LOOP
           -- Get the identifier
         OPEN c_prgm_contracts_id_seq;
         FETCH c_prgm_contracts_id_seq INTO l_prgm_contracts_rec.program_contracts_id;
         CLOSE c_prgm_contracts_id_seq;

           -- Check the uniqueness of the identifier
         OPEN c_prgm_cntrcts_id_seq_exists(l_prgm_contracts_rec.program_contracts_id);
         FETCH c_prgm_cntrcts_id_seq_exists INTO l_uniqueness_check;
           -- Exit when the identifier uniqueness is established
             EXIT WHEN c_prgm_cntrcts_id_seq_exists%ROWCOUNT = 0;
         CLOSE c_prgm_cntrcts_id_seq_exists;
     END LOOP;
   END IF;

      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - program_contracts_id = '|| l_prgm_contracts_rec.program_contracts_id);
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - Validate_Prgm_Contracts');
          END IF;

           -- Populate the default required items
           l_prgm_contracts_rec.last_update_date      := SYSDATE;
           l_prgm_contracts_rec.last_updated_by       := FND_GLOBAL.user_id;
           l_prgm_contracts_rec.creation_date         := SYSDATE;
           l_prgm_contracts_rec.created_by            := FND_GLOBAL.user_id;
           l_prgm_contracts_rec.last_update_login     := FND_GLOBAL.conc_login_id;
           l_prgm_contracts_rec.object_version_number := l_object_version_number;

          -- Invoke validation procedures
          Validate_Prgm_Contracts(
             p_api_version_number  => 1.0
            ,p_init_msg_list       => Fnd_Api.G_FALSE
            ,p_validation_level    => p_validation_level
            ,p_validation_mode     => JTF_PLSQL_API.g_create
            ,p_prgm_contracts_rec  => l_prgm_contracts_rec
            ,x_return_status       => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
            );
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' -  Validate_Prgm_Contracts return_status = ' || x_return_status );
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

      -- Invoke table handler(PV_PRGM_CONTRACTS_PKG.Insert_Row)
      PV_PRGM_CONTRACTS_PKG.Insert_Row(
           px_program_contracts_id  => l_prgm_contracts_rec.program_contracts_id
          ,p_program_id             => l_prgm_contracts_rec.program_id
          ,p_geo_hierarchy_id       => l_prgm_contracts_rec.geo_hierarchy_id
          ,p_contract_id            => l_prgm_contracts_rec.contract_id
          ,p_last_update_date       => l_prgm_contracts_rec.last_update_date
          ,p_last_updated_by        => l_prgm_contracts_rec.last_updated_by
          ,p_creation_date          => l_prgm_contracts_rec.creation_date
          ,p_created_by             => l_prgm_contracts_rec.created_by
          ,p_last_update_login      => l_prgm_contracts_rec.last_update_login
          ,p_object_version_number  => l_object_version_number
          ,p_member_type_code        => l_prgm_contracts_rec.member_type_code
          );


          x_program_contracts_id := l_prgm_contracts_rec.program_contracts_id;

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
     ROLLBACK TO CREATE_PRGM_CONTRACTS_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_PRGM_CONTRACTS_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_PRGM_CONTRACTS_PVT;
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

END Create_Prgm_Contracts;


PROCEDURE Update_Prgm_Contracts(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_prgm_contracts_rec         IN   prgm_contracts_rec_type
    )

IS

CURSOR c_get_Prgm_Contracts(cv_program_contracts_id NUMBER) IS
    SELECT *
    FROM  PV_PROGRAM_CONTRACTS
    WHERE program_contracts_id = cv_program_contracts_id;

l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Prgm_Contracts';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;

-- Local Variables
l_ref_prgm_contracts_rec             c_get_Prgm_Contracts%ROWTYPE ;
l_tar_prgm_contracts_rec             PV_PRGM_CONTRACTS_PVT.prgm_contracts_rec_type := p_prgm_contracts_rec;
l_rowid  		             ROWID;

 BEGIN
     ---------Initialize ------------------

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Prgm_Contracts_PVT;

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

      OPEN c_get_Prgm_Contracts( l_tar_prgm_contracts_rec.program_contracts_id);
      FETCH c_get_Prgm_Contracts INTO l_ref_prgm_contracts_rec  ;

       IF ( c_get_Prgm_Contracts%NOTFOUND) THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
         FND_MESSAGE.set_token('MODE','Update');
         FND_MESSAGE.set_token('ENTITY','Program_Contracts');
         FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_prgm_contracts_rec.program_contracts_id));
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: '||l_full_name||' - Close Cursor');
       END IF;
       CLOSE c_get_Prgm_Contracts;

      IF (l_tar_prgm_contracts_rec.object_version_number IS NULL OR
          l_tar_prgm_contracts_rec.object_version_number = Fnd_Api.G_MISS_NUM ) THEN

           FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
           FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
           FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Check Whether record has been changed by someone else
      IF (l_tar_prgm_contracts_rec.object_version_number <> l_ref_prgm_contracts_rec.object_version_number) THEN
           FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
           FND_MESSAGE.set_token('VALUE','PROGRAM_CONTRACTS');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API:  '||l_full_name||' - Validate_Prgm_Contracts');
          END IF;

          -- Invoke validation procedures
          Validate_Prgm_Contracts(
             p_api_version_number     => 1.0
            ,p_init_msg_list          => FND_API.G_FALSE
            ,p_validation_level       => p_validation_level
            ,p_validation_mode        => JTF_PLSQL_API.g_update
            ,p_prgm_contracts_rec     => p_prgm_contracts_rec
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
              p_prgm_contracts_rec => p_prgm_contracts_rec
             ,x_complete_rec       => l_tar_prgm_contracts_rec
             );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: '||l_full_name||' - Calling update table handler');
      END IF;

      -- Invoke table handler(PV_PRGM_CONTRACTS_PKG.Update_Row)
      PV_PRGM_CONTRACTS_PKG.Update_Row(
           p_program_contracts_id    => l_tar_prgm_contracts_rec.program_contracts_id
          ,p_program_id              => l_tar_prgm_contracts_rec.program_id
          ,p_geo_hierarchy_id        => l_tar_prgm_contracts_rec.geo_hierarchy_id
          ,p_contract_id             => l_tar_prgm_contracts_rec.contract_id
          ,p_last_update_date        => SYSDATE
          ,p_last_updated_by         => FND_GLOBAL.user_id
          ,p_last_update_login       => FND_GLOBAL.conc_login_id
          ,p_object_version_number   => l_tar_prgm_contracts_rec.object_version_number
          ,p_member_type_code         => l_tar_prgm_contracts_rec.member_type_code
          );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

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
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Prgm_Contracts_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Prgm_Contracts_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Prgm_Contracts_PVT;
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

END Update_Prgm_Contracts;

PROCEDURE Delete_Prgm_Contracts(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_program_contracts_id       IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    )

IS

l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Prgm_Contracts';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_object_version_number     NUMBER;

BEGIN

     ---- Initialize----------------

      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Prgm_Contracts_PVT;

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

      -- Invoke table handler(PV_PRGM_CONTRACTS_PKG.Delete_Row)
      PV_PRGM_CONTRACTS_PKG.Delete_Row(
          p_program_contracts_id  => p_program_contracts_id
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
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Prgm_Contracts_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Prgm_Contracts_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Prgm_Contracts_PVT;
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

END Delete_Prgm_Contracts;

PROCEDURE Lock_Prgm_Contracts(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,px_program_contracts_id       IN   NUMBER
    ,p_object_version             IN   NUMBER
    )

IS

l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_Prgm_Contracts';
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_program_contracts_id               NUMBER;

CURSOR c_Prgm_Contracts IS
   SELECT program_contracts_id
   FROM PV_PROGRAM_CONTRACTS
   WHERE program_contracts_id = px_program_contracts_id
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: ' || l_full_name || ' - start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (
      	 l_api_version_number
        ,p_api_version_number
        ,l_api_name
        ,G_PKG_NAME
        )
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


------------------------ lock -------------------------

  IF (PV_DEBUG_HIGH_ON) THEN



  Pvx_Utility_Pvt.debug_message(l_full_name||': start');

  END IF;
  OPEN c_Prgm_Contracts;

  FETCH c_Prgm_Contracts INTO l_program_contracts_id;

  IF (c_Prgm_Contracts%NOTFOUND) THEN
    CLOSE c_Prgm_Contracts;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
       Fnd_Message.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       Fnd_Msg_Pub.ADD;
    END IF;
    RAISE Fnd_Api.g_exc_error;
  END IF;

  CLOSE c_Prgm_Contracts;

 -------------------- finish --------------------------
  Fnd_Msg_Pub.count_and_get(
     p_encoded => Fnd_Api.g_false
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
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Prgm_Contracts_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Prgm_Contracts_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Prgm_Contracts_PVT;
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
END Lock_Prgm_Contracts;



PROCEDURE Check_UK_Items(
     p_prgm_contracts_rec         IN   prgm_contracts_rec_type
    ,p_validation_mode            IN   VARCHAR2 := Jtf_Plsql_Api.g_create
    ,x_return_status              OUT NOCOPY  VARCHAR2
    )

IS

   l_valid_flag  VARCHAR2(1);
   l_geo_area_name   VARCHAR2(240);
   l_program_contract_id  NUMBER;

   -- Cursor to get the geoAreaName of the given location hierarchy id
   CURSOR c_geo_area_name (l_loc_hie_id IN NUMBER) IS
      select DECODE(LH.LOCATION_TYPE_CODE, 'AREA1', LH.AREA1_NAME, 'AREA2',LH.AREA2_NAME,
                    'COUNTRY', LH.COUNTRY_NAME, 'CREGION', LH.COUNTRY_REGION_NAME,
                    'STATE', LH.STATE_NAME, 'SREGION', LH.STATE_REGION_NAME, 'CITY', LH.CITY_NAME,
                    'POSTAL_CODE', LH.POSTAL_CODE_START||'-'||LH.POSTAL_CODE_END, to_char(LOCATION_HIERARCHY_ID))
      from JTF_LOC_HIERARCHIES_VL LH
      where LOCATION_HIERARCHY_ID = l_loc_hie_id;

   CURSOR c_get_program_contract_id (cv_program_id NUMBER, cv_geo_hierarchy_id NUMBER, cv_member_type_code VARCHAR2) IS
      SELECT program_contracts_id
      FROM pv_program_contracts
      WHERE program_id = cv_program_id
            and geo_hierarchy_id = cv_geo_hierarchy_id
            and member_type_code = cv_member_type_code;

BEGIN

    x_return_status := FND_API.g_ret_sts_success;
    IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
      'PV_PROGRAM_CONTRACTS'
      ,'PROGRAM_CONTRACTS_ID = ''' || p_prgm_contracts_rec.program_contracts_id ||''''
      );

      IF l_valid_flag = Fnd_Api.g_false THEN
        FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
        FND_MESSAGE.set_token('ID',TO_CHAR(p_prgm_contracts_rec.program_contracts_id) );
        FND_MESSAGE.set_token('ENTITY','Program_Contracts');
        FND_MSG_PUB.ADD;
        x_return_status := Fnd_Api.g_ret_sts_error;
        RETURN;
      END IF;
    END IF;

      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('- In Check_UK_Items API Before PROGRAM_ID/GEO_HIERARCHY_ID combo  check' );
      END IF;

      l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
      'PV_PROGRAM_CONTRACTS'
      ,'PROGRAM_ID = ''' || p_prgm_contracts_rec.PROGRAM_ID ||''' AND GEO_HIERARCHY_ID = ''' || p_prgm_contracts_rec.GEO_HIERARCHY_ID || ''' AND MEMBER_TYPE_CODE = ''' || p_prgm_contracts_rec.member_type_code ||  ''''
      );


      IF l_valid_flag = Fnd_Api.g_false THEN
         OPEN c_get_program_contract_id(p_prgm_contracts_rec.PROGRAM_ID, p_prgm_contracts_rec.GEO_HIERARCHY_ID, p_prgm_contracts_rec.member_type_code);
         FETCH c_get_program_contract_id INTO l_program_contract_id;
         IF l_program_contract_id <> p_prgm_contracts_rec.program_contracts_id THEN

           FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');

           -- Get the get_area_name
           OPEN c_geo_area_name(p_prgm_contracts_rec.geo_hierarchy_id);
           FETCH c_geo_area_name into l_geo_area_name;
           FND_MESSAGE.set_token('ID', l_geo_area_name);

           FND_MESSAGE.set_token('ENTITY','Program Contracts');
           FND_MSG_PUB.ADD;
           x_return_status := Fnd_Api.g_ret_sts_error;
           RETURN;
         END IF;
      END IF;


/*

      IF l_valid_flag = Fnd_Api.g_false THEN
        FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');

        -- Get the get_area_name
        OPEN c_geo_area_name(p_prgm_contracts_rec.geo_hierarchy_id);
        FETCH c_geo_area_name into l_geo_area_name;
        FND_MESSAGE.set_token('ID', l_geo_area_name);

        FND_MESSAGE.set_token('ENTITY','Program_Contracts');
        FND_MSG_PUB.ADD;
        x_return_status := Fnd_Api.g_ret_sts_error;
        RETURN;
      END IF;
   END IF;
*/
END Check_UK_Items;



PROCEDURE Check_Req_Items(
     p_prgm_contracts_rec    IN  prgm_contracts_rec_type
    ,p_validation_mode       IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status	     OUT NOCOPY VARCHAR2
    )

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_prgm_contracts_rec.program_contracts_id = Fnd_Api.g_miss_num
        OR p_prgm_contracts_rec.program_contracts_id IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','PROGRAM_CONTRACTS_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_contracts_rec.program_id = Fnd_Api.g_miss_num
       OR p_prgm_contracts_rec.program_id IS NULL THEN
         Fnd_Message.set_name('PV','PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','PROGRAM_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_contracts_rec.geo_hierarchy_id = Fnd_Api.g_miss_num
       OR p_prgm_contracts_rec.geo_hierarchy_id IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','GEO_HIERARCHY_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_contracts_rec.contract_id = Fnd_Api.g_miss_num
       OR p_prgm_contracts_rec.contract_id IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','CONTRACT_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_contracts_rec.last_update_date = Fnd_Api.g_miss_date
       OR p_prgm_contracts_rec.last_update_date IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','LAST_UPDATE_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_contracts_rec.last_updated_by = Fnd_Api.g_miss_num
       OR p_prgm_contracts_rec.last_updated_by IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','LAST_UPDATED_BY');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_contracts_rec.creation_date = Fnd_Api.g_miss_date
       OR p_prgm_contracts_rec.creation_date IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','CREATION_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_contracts_rec.created_by = Fnd_Api.g_miss_num
       OR p_prgm_contracts_rec.created_by IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','CREATED_BY');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_contracts_rec.last_update_login = Fnd_Api.g_miss_num
       OR p_prgm_contracts_rec.last_update_login IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','LAST_UPDATE_LOGIN');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_contracts_rec.object_version_number = Fnd_Api.g_miss_num
       OR p_prgm_contracts_rec.object_version_number IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','OBJECT_VERSION_NUMBER');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_prgm_contracts_rec.member_type_code = Fnd_Api.g_miss_char
       OR p_prgm_contracts_rec.member_type_code IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','MEMBER_TYPE_CODE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   ELSE


      IF p_prgm_contracts_rec.program_contracts_id IS NULL THEN
          Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          Fnd_Message.set_token('COLUMN','PROGRAM_CONTRACTS_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_prgm_contracts_rec.object_version_number IS NULL THEN
          Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
          Fnd_Message.set_token('COLUMN','object_version_number');
          Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Req_Items;



PROCEDURE Check_FK_Items(
     p_prgm_contracts_rec   IN  prgm_contracts_rec_type
    ,x_return_status        OUT NOCOPY VARCHAR2
    )
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

 ----------------------- PROGRAM_ID ------------------------
 IF (p_prgm_contracts_rec.PROGRAM_ID <> FND_API.g_miss_num
       AND p_prgm_contracts_rec.PROGRAM_ID IS NOT NULL ) THEN

 -- Debug message
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('- In Check_FK_Items : Before PROGRAM_ID fk check : PROGRAM_ID ' || p_prgm_contracts_rec.PROGRAM_ID);
 END IF;

   IF PVX_Utility_PVT.check_fk_exists(
         'PV_PARTNER_PROGRAM_B',                     -- Parent schema object having the primary key
         'PROGRAM_ID',                               -- Column name in the parent object that maps to the fk value
         p_prgm_contracts_rec.PROGRAM_ID,            -- Value of fk to be validated against the parent object's pk column
         PVX_UTILITY_PVT.g_number,                   -- datatype of fk
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

 IF (PV_DEBUG_HIGH_ON) THEN



 PVX_UTILITY_PVT.debug_message('In Check_FK_Items : After program_id fk check ');

 END IF;

 ----------------------- GEO_HIERARCHY_ID ------------------------
 IF (p_prgm_contracts_rec.GEO_HIERARCHY_ID <> FND_API.g_miss_num
       AND p_prgm_contracts_rec.GEO_HIERARCHY_ID IS NOT NULL ) THEN

 -- Debug message
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('- In Check_FK_Items : Before GEO_HIERARCHY_ID fk check : GEO_HIERARCHY_ID ' || p_prgm_contracts_rec.GEO_HIERARCHY_ID);
 END IF;

   IF PVX_Utility_PVT.check_fk_exists(
         'JTF_LOC_HIERARCHIES_VL',                   -- Parent schema object having the primary key
         'LOCATION_HIERARCHY_ID',                    -- Column name in the parent object that maps to the fk value
         p_prgm_contracts_rec.GEO_HIERARCHY_ID,      -- Value of fk to be validated against the parent object's pk column
         PVX_UTILITY_PVT.g_number,                   -- datatype of fk
         NULL
   ) = FND_API.g_false
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_GEO_HIERARCHY');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
 END IF;

 ----------------------- CONTRACT_ID ------------------------
 IF (p_prgm_contracts_rec.CONTRACT_ID <> FND_API.g_miss_num
       AND p_prgm_contracts_rec.CONTRACT_ID IS NOT NULL ) THEN

 -- Debug message
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('- In Check_FK_Items : Before CONTRACT_ID fk check : CONTRACT_ID ' || p_prgm_contracts_rec.CONTRACT_ID);
 END IF;

   IF PVX_Utility_PVT.check_fk_exists(
         'OKC_TERMS_TEMPLATES_ALL',             -- Parent schema object having the primary key
         'TEMPLATE_ID',                         -- Column name in the parent object that maps to the fk value
         p_prgm_contracts_rec.CONTRACT_ID,      -- Value of fk to be validated against the parent object's pk column
         PVX_UTILITY_PVT.g_number,              -- datatype of fk
         NULL
   ) = FND_API.g_false
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_CONTRACT');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
 END IF;

END Check_FK_Items;



PROCEDURE Check_Lookup_Items(
    p_prgm_contracts_rec   IN   prgm_contracts_rec_type
    ,x_return_status       OUT NOCOPY  VARCHAR2
    )
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- No Lookup Items for PV_Program_Contracts Table

END Check_Lookup_Items;



PROCEDURE Check_Items (
     p_prgm_contracts_rec     IN    prgm_contracts_rec_type
    ,p_validation_mode        IN    VARCHAR2
    ,x_return_status          OUT NOCOPY   VARCHAR2
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
       p_prgm_contracts_rec => p_prgm_contracts_rec
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
       p_prgm_contracts_rec => p_prgm_contracts_rec
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
       p_prgm_contracts_rec  => p_prgm_contracts_rec
      ,x_return_status       => x_return_status
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
       p_prgm_contracts_rec  => p_prgm_contracts_rec
      ,x_return_status       => x_return_status);
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Items;



PROCEDURE Complete_Rec (
    p_prgm_contracts_rec IN  prgm_contracts_rec_type
   ,x_complete_rec       OUT NOCOPY prgm_contracts_rec_type
   )
IS

   CURSOR c_complete IS
      SELECT *
      FROM PV_PROGRAM_CONTRACTS
      WHERE program_contracts_id = p_prgm_contracts_rec.program_contracts_id;

   l_prgm_contracts_rec c_complete%ROWTYPE;

BEGIN

   x_complete_rec := p_prgm_contracts_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_prgm_contracts_rec;
   CLOSE c_complete;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Complete_Rec API prior to assigning program_id');
   END IF;

   -- program_contracts_id
   --IF p_prgm_contracts_rec.program_contracts_id = Fnd_Api.g_miss_num THEN
   IF p_prgm_contracts_rec.program_contracts_id IS NULL THEN
      x_complete_rec.program_contracts_id := l_prgm_contracts_rec.program_contracts_id;
   END IF;

   -- program_id
   --IF p_prgm_contracts_rec.program_id = Fnd_Api.g_miss_num THEN
   IF p_prgm_contracts_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_prgm_contracts_rec.program_id;
   END IF;

   -- geo_hierarchy_id
   --IF p_prgm_contracts_rec.geo_hierarchy_id = Fnd_Api.g_miss_num THEN
   IF p_prgm_contracts_rec.geo_hierarchy_id IS NULL THEN
      x_complete_rec.geo_hierarchy_id := l_prgm_contracts_rec.geo_hierarchy_id;
   END IF;

   -- contract_id
   --IF p_prgm_contracts_rec.contract_id = Fnd_Api.g_miss_num THEN
   IF p_prgm_contracts_rec.contract_id IS NULL  THEN
      x_complete_rec.contract_id := l_prgm_contracts_rec.contract_id;
   END IF;

   -- last_update_date
   --IF p_prgm_contracts_rec.last_update_date = Fnd_Api.g_miss_date THEN
   IF p_prgm_contracts_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_prgm_contracts_rec.last_update_date;
   END IF;

   -- last_updated_by
   --IF p_prgm_contracts_rec.last_updated_by = Fnd_Api.g_miss_num THEN
   IF p_prgm_contracts_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_prgm_contracts_rec.last_updated_by;
   END IF;

   -- creation_date
   --IF p_prgm_contracts_rec.creation_date = Fnd_Api.g_miss_date THEN
   IF p_prgm_contracts_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_prgm_contracts_rec.creation_date;
   END IF;

   -- created_by
   --IF p_prgm_contracts_rec.created_by = Fnd_Api.g_miss_num THEN
   IF p_prgm_contracts_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_prgm_contracts_rec.created_by;
   END IF;

   -- last_update_login
   --IF p_prgm_contracts_rec.last_update_login = Fnd_Api.g_miss_num THEN
   IF p_prgm_contracts_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_prgm_contracts_rec.last_update_login;
   END IF;

   -- object_version_number
   --IF p_prgm_contracts_rec.object_version_number = Fnd_Api.g_miss_num THEN
   IF p_prgm_contracts_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_prgm_contracts_rec.object_version_number;
   END IF;

   -- member_type_code
   --IF p_prgm_contracts_rec.member_type_code = Fnd_Api.g_miss_char THEN
   IF p_prgm_contracts_rec.member_type_code IS NULL  THEN
      x_complete_rec.member_type_code := l_prgm_contracts_rec.member_type_code;
   END IF;

END Complete_Rec;



PROCEDURE Validate_Prgm_Contracts(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,p_prgm_contracts_rec         IN   prgm_contracts_rec_type
    ,p_validation_mode            IN   VARCHAR2
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    )

IS

l_api_name                 CONSTANT VARCHAR2(30) := 'Validate_Prgm_Contracts';
l_full_name                CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number       CONSTANT NUMBER       := 1.0;
l_object_version_number             NUMBER;
l_prgm_contracts_rec                PV_PRGM_CONTRACTS_PVT.prgm_contracts_rec_type;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Prgm_Contracts_;

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
                  p_prgm_contracts_rec  => p_prgm_contracts_rec
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
           ,p_init_msg_list          => Fnd_Api.G_FALSE
           ,x_return_status          => x_return_status
           ,x_msg_count              => x_msg_count
           ,x_msg_data               => x_msg_data
           ,p_prgm_contracts_rec     => l_prgm_contracts_rec
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

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Prgm_Contracts_;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Prgm_Contracts_;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Prgm_Contracts_;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );

END Validate_Prgm_Contracts;


PROCEDURE Validate_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_prgm_contracts_rec         IN   prgm_contracts_rec_type
    ,p_validation_mode            IN   VARCHAR2
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
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: Validate_dm_model_rec');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get(
          p_count          =>   x_msg_count
         ,p_data           =>   x_msg_data
      );

END Validate_Rec;

END PV_PRGM_CONTRACTS_PVT;

/
