--------------------------------------------------------
--  DDL for Package Body OZF_PROCESS_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PROCESS_SETUP_PVT" as
/* $Header: ozfvpseb.pls 120.5 2008/07/04 04:23:27 kdass noship $ */
-- Start of Comments
-- Package name     : ozf_process_setup_pvt
-- Purpose          :
-- History          : 10-NOV-2007  gdeepika   Created
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ozf_process_setup_pvt';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvpseb.pls';
G_PARTY_ID     NUMBER;
G_ACCOUNT_ID   NUMBER;

PROCEDURE create_process_setup
(
   p_api_version_number         IN          NUMBER,
   p_init_msg_list              IN          VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN          VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN          NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_process_setup_tbl        IN          process_setup_tbl_type,
   x_process_setup_id_tbl     OUT NOCOPY  JTF_NUMBER_TABLE
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'create_process_setup';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER;
   l_process_setup_id        NUMBER;
   l_process_setup_rec       process_setup_rec_type;
   TYPE process_code_table_type IS TABLE OF VARCHAR2(30);
   process_code_tbl process_code_table_type;
    flag boolean :=false;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_process_setup_pvt;

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


      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_USER_PROFILE_MISSING');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
        END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'No of records to be created'||p_process_setup_tbl.count);
        END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name);
          -- Invoke validation procedures
          Validate_Process_Setup(
            p_api_version_number     => 1.0,
            p_init_msg_list              => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_validation_mode        => JTF_PLSQL_API.G_CREATE,
                p_process_setup_tbl      => p_process_setup_tbl,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
        END IF;

      l_process_setup_id     := NULL;
      l_object_version_number  := 1;

      x_process_setup_id_tbl := JTF_NUMBER_TABLE();

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
          OZF_UTILITY_PVT.debug_message( 'No of rows to be created '|| p_process_setup_tbl.count);
        END IF;




      FOR i IN 1 .. p_process_setup_tbl.count
      LOOP

        l_process_setup_rec := p_process_setup_tbl(i);

        IF (l_process_setup_rec.org_id IS NULL)      THEN
             l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements
        ELSE
             l_org_id := l_process_setup_rec.org_id;
        END IF;
        SELECT ozf_process_setup_all_s.nextval INTO l_process_setup_id FROM DUAL;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
            OZF_UTILITY_PVT.debug_message( 'l_org_id ' || l_org_id);
            OZF_UTILITY_PVT.debug_message( 'Process Setup ID '|| l_process_setup_id);
        END IF;

        BEGIN


        OZF_PROCESS_SETUP_PKG.Insert_Row(
          px_process_setup_id       =>    l_process_setup_id,
          px_object_version_number  =>    l_object_version_number,
          p_last_update_date        =>    SYSDATE,
          p_last_updated_by         =>    FND_GLOBAL.USER_ID,
          p_creation_date           =>    SYSDATE,
          p_created_by              =>    FND_GLOBAL.USER_ID,
          p_last_update_login       =>    FND_GLOBAL.CONC_LOGIN_ID,
          px_org_id                 =>    l_org_id,
          p_supp_trade_profile_id   =>    l_process_setup_rec.supp_trade_profile_id,
          p_process_code            =>    l_process_setup_rec.process_code,
          p_enabled_flag            =>    l_process_setup_rec.enabled_flag,
          p_automatic_flag          =>    l_process_setup_rec.automatic_flag,
          p_attribute_category      =>    l_process_setup_rec.attribute_category,
          p_attribute1              =>    l_process_setup_rec.attribute1,
          p_attribute2              =>    l_process_setup_rec.attribute2,
          p_attribute3              =>    l_process_setup_rec.attribute3,
          p_attribute4              =>    l_process_setup_rec.attribute4,
          p_attribute5              =>    l_process_setup_rec.attribute5,
          p_attribute6              =>    l_process_setup_rec.attribute6,
          p_attribute7              =>    l_process_setup_rec.attribute7,
          p_attribute8              =>    l_process_setup_rec.attribute8,
          p_attribute9              =>    l_process_setup_rec.attribute9,
          p_attribute10             =>    l_process_setup_rec.attribute10,
          p_attribute11             =>    l_process_setup_rec.attribute11,
          p_attribute12             =>    l_process_setup_rec.attribute12,
          p_attribute13             =>    l_process_setup_rec.attribute13,
          p_attribute14             =>    l_process_setup_rec.attribute14,
          p_attribute15             =>    l_process_setup_rec.attribute15);

        EXCEPTION
          WHEN OTHERS THEN
              OZF_UTILITY_PVT.debug_message (SQLERRM ||'  Error in creating process setup');
              RAISE FND_API.G_EXC_ERROR;
        END;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' after insert call - code conversion id' || l_process_setup_id);
           OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' after insert call - obj version no ' || l_process_setup_rec.Object_Version_Number);
        END IF;

      x_process_setup_id_tbl.extend;
      x_process_setup_id_tbl(x_process_setup_id_tbl.count) :=  l_process_setup_id;

   END LOOP;



-- new code for inserting the remaining process code records during creation.

 --CURSOR csr_process_setup(pc_table process_code_table_type)
 -- IS
    SELECT lookup_code
    BULK COLLECT INTO process_code_tbl
    FROM dpp_lookups fl
    WHERE fl.lookup_type='DPP_EXECUTION_PROCESSES'
    AND nvl(fl.start_date_active,sysdate) <= sysdate
    AND nvl(fl.end_date_active,sysdate) >= sysdate
    AND fl.enabled_flag= 'Y'
    AND fl.tag IS NOT NULL;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
        OZF_UTILITY_PVT.debug_message('code table count'||process_code_tbl.count);
        end if;
      l_process_setup_rec := p_process_setup_tbl(1);
      IF (l_process_setup_rec.org_id IS NULL)      THEN
            l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements
      ELSE
          l_org_id := l_process_setup_rec.org_id;
      END IF;

      FOR i IN  process_code_tbl.first..process_code_tbl.last
      LOOP
        flag := true;
        FOR j IN  p_process_setup_tbl.first..p_process_setup_tbl.last
        LOOP
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
             OZF_UTILITY_PVT.debug_message('i is '||i);
             OZF_UTILITY_PVT.debug_message('J'||j);
             OZF_UTILITY_PVT.debug_message(' for p_process_setup_tbl(j).process_code'||p_process_setup_tbl(j).process_code||'--process_code_tbl(i)'||process_code_tbl(i));
          end if;
        if (p_process_setup_tbl(j).process_code = process_code_tbl(i))
        then
         flag := false;
         exit;
        end if;
        if(flag = false) then
        exit;
        end if;
        END LOOP;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
        OZF_UTILITY_PVT.debug_message('for p_process_setup_tbl(j).process_code'||'--'||process_code_tbl(i));
        end if;
        IF (flag = true) THEN

           SELECT ozf_process_setup_all_s.nextval INTO l_process_setup_id FROM DUAL;

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
              OZF_UTILITY_PVT.debug_message('l_process_setup_id and i '||i||l_process_setup_id);
              OZF_UTILITY_PVT.debug_message('org_id and i '||i||l_org_id);
              OZF_UTILITY_PVT.debug_message('l_object_version_number and i '||i||l_object_version_number);
              OZF_UTILITY_PVT.debug_message('l_process_setup_rec.supp_trade_profile_id and i '||i||l_process_setup_rec.supp_trade_profile_id);
              OZF_UTILITY_PVT.debug_message('process_code_tbl(i) and i '||i||process_code_tbl(i));

              OZF_UTILITY_PVT.debug_message( 'l_org_id ' || l_org_id);
              OZF_UTILITY_PVT.debug_message( 'Process Setup ID '|| l_process_setup_id);

           END IF;

       BEGIN
        OZF_PROCESS_SETUP_PKG.Insert_Row(
          px_process_setup_id       =>    l_process_setup_id,
          px_object_version_number  =>    l_object_version_number,
          p_last_update_date        =>    SYSDATE,
          p_last_updated_by         =>    FND_GLOBAL.USER_ID,
          p_creation_date           =>    SYSDATE,
          p_created_by              =>    FND_GLOBAL.USER_ID,
          p_last_update_login       =>    FND_GLOBAL.CONC_LOGIN_ID,
          px_org_id                 =>    l_org_id,
          p_supp_trade_profile_id   =>    l_process_setup_rec.supp_trade_profile_id,
          p_process_code            =>    process_code_tbl(i),
          p_enabled_flag            =>    'N',
          p_automatic_flag          =>    'N',
          p_attribute_category      =>    NULL,
          p_attribute1              =>    NULL,
          p_attribute2              =>    NULL,
          p_attribute3              =>    NULL,
          p_attribute4              =>    NULL,
          p_attribute5              =>    NULL,
          p_attribute6              =>    NULL,
          p_attribute7              =>    NULL,
          p_attribute8              =>    NULL,
          p_attribute9              =>    NULL,
          p_attribute10             =>    NULL,
          p_attribute11             =>    NULL,
          p_attribute12             =>    NULL,
          p_attribute13             =>    NULL,
          p_attribute14             =>    NULL,
          p_attribute15             =>    NULL);

        EXCEPTION
          WHEN OTHERS THEN
              OZF_UTILITY_PVT.debug_message (SQLERRM ||'  Error in creating process setup');
              RAISE FND_API.G_EXC_ERROR;
        END;
        else
         OZF_UTILITY_PVT.debug_message('flag was false');
        end if ;
     END LOOP;
     -- RAISE FND_API.G_EXC_ERROR;
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );



EXCEPTION
  WHEN OZF_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCES_LOCKED');
            FND_MSG_PUB.add;
     END IF;
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_process_setup_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_process_setup_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
  WHEN OTHERS THEN
     ROLLBACK TO create_process_setup_pvt;
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

END create_process_setup ;


PROCEDURE Update_process_setup
(
    p_api_version_number         IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_process_setup_tbl        IN          process_setup_tbl_type  ,
    x_object_version_number      OUT NOCOPY  JTF_NUMBER_TABLE
    )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Update_process_setup';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_object_version_number   NUMBER;

  l_process_setup_id  NUMBER;

  CURSOR csr_process_setup(cv_process_setup_id NUMBER)
  IS
  SELECT  process_setup_id,
         object_version_number,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         org_id,
         supp_trade_profile_id,
             process_code,
         enabled_flag,
         automatic_flag,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         security_group_id
 FROM    ozf_process_setup_all
 WHERE   process_setup_id = cv_process_setup_id;

 CURSOR get_org
 IS
 SELECT org_id FROM ozf_sys_parameters;

l_process_setup_rec   process_setup_rec_type;
l_process_setup_tbl   process_setup_tbl_type;
l_org_id                NUMBER;
p_process_setup_rec   process_setup_rec_type;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_process_setup_pvt;

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

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_USER_PROFILE_MISSING');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
          OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
       END IF;

      -- Initialize API return status to SUCCESS
      x_return_status         := FND_API.G_RET_STS_SUCCESS;
      x_object_version_number := JTF_NUMBER_TABLE();


      FOR i in 1 .. p_process_setup_tbl.count
      LOOP
        p_process_setup_rec := p_process_setup_tbl(i);
        l_process_setup_id  := p_process_setup_rec.process_setup_id;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'In Update :Process Setup ID' || l_process_setup_id);
        END IF;

      --  Check for the existance of the record
        OPEN csr_process_setup(l_process_setup_id);
        FETCH csr_process_setup
        INTO   l_process_setup_rec.process_setup_id
              ,l_process_setup_rec.object_version_number
              ,l_process_setup_rec.last_update_date
              ,l_process_setup_rec.last_updated_by
              ,l_process_setup_rec.creation_date
              ,l_process_setup_rec.created_by
              ,l_process_setup_rec.last_update_login
              ,l_process_setup_rec.org_id
              ,l_process_setup_rec.supp_trade_profile_id
                  ,l_process_setup_rec.process_code
              ,l_process_setup_rec.enabled_flag
              ,l_process_setup_rec.automatic_flag
              ,l_process_setup_rec.attribute_category
              ,l_process_setup_rec.attribute1
              ,l_process_setup_rec.attribute2
              ,l_process_setup_rec.attribute3
              ,l_process_setup_rec.attribute4
              ,l_process_setup_rec.attribute5
              ,l_process_setup_rec.attribute6
              ,l_process_setup_rec.attribute7
              ,l_process_setup_rec.attribute8
              ,l_process_setup_rec.attribute9
              ,l_process_setup_rec.attribute10
              ,l_process_setup_rec.attribute11
              ,l_process_setup_rec.attribute12
              ,l_process_setup_rec.attribute13
              ,l_process_setup_rec.attribute14
              ,l_process_setup_rec.attribute15
              ,l_process_setup_rec.security_group_id;


         IF ( csr_process_setup%NOTFOUND) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
              OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'nodata for upd');
            END IF;

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
              FND_MSG_PUB.add;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
        CLOSE csr_process_setup;


        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
          OZF_UTILITY_PVT.debug_message( 'Pre Object Version Number ' || l_process_setup_rec.object_version_number);
          OZF_UTILITY_PVT.debug_message( 'Post Object Version Number' || P_process_setup_rec.object_version_number);
        END IF;

      --- Check the Version Number for Locking
        IF l_process_setup_rec.object_version_number <> P_process_setup_rec.Object_Version_number
        THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
               OZF_UTILITY_PVT.debug_message( 'dbver' || l_process_setup_rec.object_version_number);
               OZF_UTILITY_PVT.debug_message( 'reqver' || P_process_setup_rec.object_version_number);
            END IF;

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
             FND_MESSAGE.Set_Name('OZF', 'OZF_API_RESOURCE_LOCKED');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
        -- Debug message
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
             OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name);
          END IF;
        -- Invoke validation procedures
            Validate_process_setup(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_validation_mode        => JTF_PLSQL_API.G_UPDATE,
            p_process_setup_tbl      => p_process_setup_tbl,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);
        END IF;

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_process_setup_rec.org_id IS NULL) THEN
            l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements
        ELSE
           l_org_id := l_process_setup_rec.org_id;
        END IF;


     -- Call Update Table Handler
     -- Debug Message
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'Private API: Calling Update table handler');
        END IF;
        BEGIN
           OZF_PROCESS_SETUP_PKG.Update_Row(
           p_process_setup_id      =>    l_process_setup_id,
           p_object_version_number  =>     p_process_setup_rec.object_version_number,
           p_last_update_date       =>     SYSDATE,
           p_last_updated_by        =>     FND_GLOBAL.USER_ID,
           p_last_update_login      =>     FND_GLOBAL.CONC_LOGIN_ID,
           p_org_id                 =>     l_org_id,
           p_supp_trade_profile_id  =>     p_process_setup_rec.supp_trade_profile_id,
           p_process_code           =>     p_process_setup_rec.process_code,
           p_enabled_flag           =>     p_process_setup_rec.enabled_flag,
           p_automatic_flag         =>     p_process_setup_rec.automatic_flag,
           p_attribute_category     =>     p_process_setup_rec.attribute_category,
           p_attribute1             =>     p_process_setup_rec.attribute1,
           p_attribute2             =>     p_process_setup_rec.attribute2,
           p_attribute3             =>     p_process_setup_rec.attribute3,
           p_attribute4             =>     p_process_setup_rec.attribute4,
           p_attribute5             =>     p_process_setup_rec.attribute5,
           p_attribute6             =>     p_process_setup_rec.attribute6,
           p_attribute7             =>     p_process_setup_rec.attribute7,
           p_attribute8             =>     p_process_setup_rec.attribute8,
           p_attribute9             =>     p_process_setup_rec.attribute9,
           p_attribute10            =>     p_process_setup_rec.attribute10,
           p_attribute11            =>     p_process_setup_rec.attribute11,
           p_attribute12            =>     p_process_setup_rec.attribute12,
           p_attribute13            =>     p_process_setup_rec.attribute13,
           p_attribute14            =>     p_process_setup_rec.attribute14,
           p_attribute15            =>     p_process_setup_rec.attribute15);



        EXCEPTION
           WHEN OTHERS THEN
             OZF_UTILITY_PVT.debug_message (SQLERRM ||'  Error in updating OZF_PROCESS_SETUP table');
             RAISE FND_API.G_EXC_ERROR;
       END;
        x_object_version_number.EXTEND;
        x_object_Version_number(x_object_version_number.count) := p_process_setup_rec.Object_Version_Number;

     END LOOP;
   --END IF;

     -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit )
     THEN
         COMMIT WORK;
     END IF;


     -- Debug Message
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
        OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_process_setup_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_process_setup_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO update_process_setup_pvt;
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

END Update_process_Setup;



PROCEDURE Update_Process_Setup_Tbl(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    P_process_setup_Tbl        IN  process_setup_tbl_type
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'update_process_setup_tbl';
l_api_version_number      CONSTANT NUMBER   := 1.0;

p_process_setup_rec     process_setup_rec_type;

l_process_setup_id      NUMBER;
v_process_setup_id      JTF_NUMBER_TABLE;
v_object_version_number   JTF_NUMBER_TABLE;

l_create_flag             VARCHAR2(10);

l_create_pro_setup_tbl    process_setup_tbl_type := process_setup_tbl_type();
l_update_pro_setup_tbl    process_setup_tbl_type := process_setup_tbl_type();

l_cc_cnt                  NUMBER := 0;
l_up_cnt                  NUMBER := 0;

BEGIN
      -- Standard Start of API savepoint
     SAVEPOINT update_process_setup_tbl_pvt;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
        OZF_UTILITY_PVT.debug_message('Entered the proc tbl');
     END IF;

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

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_USER_PROFILE_MISSING');
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
         OZF_UTILITY_PVT.debug_message('Total Number of records '||P_process_setup_Tbl.count);
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      v_process_setup_id    :=   JTF_NUMBER_TABLE();
      v_object_version_number :=   JTF_NUMBER_TABLE();

      FOR i IN P_process_setup_Tbl.first .. P_process_setup_Tbl.last
      LOOP
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message('i' ||i);
      OZF_UTILITY_PVT.debug_message('P_process_setup_Tbl(i).process_setup_id'||P_process_setup_Tbl(i).process_setup_id);
      OZF_UTILITY_PVT.debug_message('P_process_setup_Tbl(i).org_id'||P_process_setup_Tbl(i).org_id);
      OZF_UTILITY_PVT.debug_message('P_process_setup_Tbl(i).enabled_flag'||P_process_setup_Tbl(i).enabled_flag);
      OZF_UTILITY_PVT.debug_message('P_process_setup_Tbl(i).automatic_flag'||P_process_setup_Tbl(i).automatic_flag);
      OZF_UTILITY_PVT.debug_message('P_process_setup_Tbl(i).supp_trade_profile_id'||P_process_setup_Tbl(i).supp_trade_profile_id);
      OZF_UTILITY_PVT.debug_message('P_process_setup_Tbl(i).process_code'||P_process_setup_Tbl(i).process_code);
      end if;
--      OZF_UTILITY_PVT.debug_message('P_process_setup_Tbl(i).process_setup_id'||P_process_setup_Tbl(i).process_setup_id);
          l_process_setup_id := P_process_setup_Tbl(i).process_setup_id;
          P_process_setup_Rec := P_process_setup_Tbl(i);




         IF l_process_setup_id IS NULL OR l_process_setup_id  = -1   then
             l_cc_cnt := l_cc_cnt + 1;

             l_create_pro_setup_tbl.extend;
             l_create_pro_setup_tbl(l_cc_cnt) := P_process_setup_Rec;

          ELSE
             l_up_cnt := l_up_cnt + 1;

             l_update_pro_setup_tbl.extend;
             l_update_pro_setup_tbl(l_up_cnt) := P_process_setup_Rec;
          END IF;



      END LOOP;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('No of rows to be created: ' || l_cc_cnt);
         OZF_UTILITY_PVT.debug_message('No of rows to be updated: ' || l_up_cnt);
      END IF;

      IF  l_cc_cnt > 0 THEN
             --- Call to Create Procedure
             Create_process_setup
             (
                p_api_version_number         =>  p_api_version_number,
                p_init_msg_list              =>  p_init_msg_list,
                p_commit                     =>  p_commit,
                p_validation_level           =>  p_validation_level,
                x_return_status              =>  x_return_Status,
                x_msg_count                  =>  x_msg_Count,
                x_msg_data                   =>  x_msg_Data,
                p_process_setup_tbl        =>  l_create_pro_setup_tbl,
                x_process_setup_id_tbl     =>  v_process_setup_id
              );

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
      END IF;

      IF l_up_cnt > 0 THEN
              -- Call to Update Procedure
            Update_process_setup (
               p_api_version_number         =>  p_api_version_number ,
               p_init_msg_list              =>  p_init_msg_list,
               p_commit                     =>  p_commit,
               p_validation_level           =>  p_validation_level,
               x_return_status              =>  x_return_Status,
               x_msg_count                  =>  x_msg_Count,
               x_msg_data                   =>  x_msg_Data,
               p_process_setup_tbl        =>  l_update_pro_setup_tbl,
               x_object_version_number      =>  v_object_version_number
              );

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
       END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_process_setup_tbl_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_process_setup_tbl_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO update_process_setup_tbl_pvt;
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


END Update_Process_Setup_Tbl;



PROCEDURE Check_uniq_process_setup(
    p_process_setup_rec       IN    process_setup_rec_type,
    p_validation_mode           IN    VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY   VARCHAR2
)
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Check_uniq_process_setup';
  l_api_version_number      CONSTANT NUMBER   := 1.0;


   CURSOR csr_pro_setup_4stp(cv_supp_trade_profile_id NUMBER
                             ,cv_process_code VARCHAR2)
   IS
      SELECT COUNT(process_setup_id)
      FROM   ozf_process_setup_all
      WHERE  process_code =  cv_process_code
      AND supp_trade_profile_id = cv_supp_trade_profile_id ;

   CURSOR csr_pro_setup_4org(cv_process_code VARCHAR2,
                             cv_org_id  NUMBER
                            )
   IS
     SELECT COUNT(process_setup_id)
     FROM   ozf_process_setup_all
     WHERE supp_trade_profile_id IS NULL
     AND org_id = cv_org_id
     AND process_code = cv_process_code ;


   l_valid_flag         VARCHAR2(30);
   l_psi_dummy          NUMBER := 0;



BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message('in '||l_api_name);

   END IF;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_process_setup_rec.supp_trade_profile_id = FND_API.g_miss_num OR
         p_process_setup_rec.supp_trade_profile_id IS NULL
          THEN
            l_psi_dummy := 0;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
               OZF_UTILITY_PVT.debug_message('Enabled flag '  ||p_process_setup_rec.enabled_flag );
               OZF_UTILITY_PVT.debug_message('Org ID '  || p_process_setup_rec.org_id );
            END IF;

            OPEN csr_pro_setup_4org(p_process_setup_rec.process_code,p_process_setup_rec.org_id);
            FETCH csr_pro_setup_4org
            INTO  l_psi_dummy;
            CLOSE csr_pro_setup_4org;


            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
               OZF_UTILITY_PVT.debug_message('Duplicate Process setup id' || p_process_setup_rec.process_setup_id );
            END IF;
            IF l_psi_dummy > 0 THEN
               l_valid_flag :=  FND_API.g_false;
            END IF;
         ELSE
           l_psi_dummy := NULL;
           OPEN csr_pro_setup_4stp(  p_process_setup_rec.supp_trade_profile_id,
                                     p_process_setup_rec.process_code);
           FETCH csr_pro_setup_4stp
           INTO  l_psi_dummy;
           CLOSE csr_pro_setup_4stp;




           IF l_psi_dummy > 0 THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_DUPLICATE_PROCESS_SETUP');
              FND_MSG_PUB.add;
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              l_valid_flag :=  FND_API.g_false;
           END IF;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
              OZF_UTILITY_PVT.debug_message('Count of code map for psi ' || l_psi_dummy);
            END IF;
         END IF;
   ELSE -- for update mode
      l_valid_flag := FND_API.g_true;
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_DUPLICATE_PROCESS_SETUP');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

END Check_Uniq_Process_Setup;


-- Start of Comments
--
-- Required Items Check procedure
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments


PROCEDURE  check_process_setup_items
(
   p_process_setup_rec   IN    process_setup_rec_type,
   p_validation_mode       IN    VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2
)

IS
  l_api_name                CONSTANT VARCHAR2(30) := 'check_process_setup_items';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message('in '||l_api_name);
   END IF;

   IF p_process_setup_rec.org_id = FND_API.g_miss_num OR
         p_process_setup_rec.org_id IS NULL
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ORG_ID_MISSING');
         FND_MSG_PUB.add;
      END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

    check_uniq_process_setup( p_process_setup_rec,
                                p_validation_mode,
                                x_return_status
                                 );
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
       OZF_UTILITY_PVT.debug_message('after check_uniq_process_setup ' );
    END IF;


END check_process_setup_items;
-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments

PROCEDURE Validate_Process_Setup(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2,
    p_process_setup_tbl        IN    process_setup_tbl_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )

IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Validate_process_setup';
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   l_object_version_number   NUMBER;

   l_process_setup_rec     process_setup_rec_type ;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_process_setup_pvt;

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
      -- Call the Validate Item procedure for the item(field level validations )
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('in '||l_api_name );
      END IF;
      x_return_status := FND_API.g_ret_sts_success;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

      FOR i in 1 .. p_process_setup_tbl.count
      LOOP
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
            OZF_UTILITY_PVT.debug_message('inside the loop p_process_setup_tbl ' );
         END IF;
         l_process_setup_rec := p_process_setup_tbl(i);

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
            OZF_UTILITY_PVT.debug_message('Enabled flag '  || l_process_setup_rec.enabled_flag );
            OZF_UTILITY_PVT.debug_message('automatic flag '|| l_process_setup_rec.automatic_flag );
            OZF_UTILITY_PVT.debug_message('Process code'  || l_process_setup_rec.process_code );
         END IF;

         check_process_setup_items(
           p_process_setup_rec      => l_process_setup_rec,
           p_validation_mode          => p_validation_mode,
           x_return_status            => x_return_status);


         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END LOOP;

      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
        );
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCE_LOCKED ');
            FND_MSG_PUB.add;
      END IF;
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_process_setup_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO validate_process_setup_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO validate_process_setup_pvt;
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

END Validate_process_setup;
END Ozf_Process_Setup_Pvt;





/
