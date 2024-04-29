--------------------------------------------------------
--  DDL for Package Body OZF_CODE_CONVERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CODE_CONVERSION_PVT" as
/* $Header: ozfvsccb.pls 120.10 2008/03/28 06:30:28 gdeepika ship $ */
-- Start of Comments
-- Package name     : ozf_code_conversion_pvt
-- Purpose          :
-- History          : 09-OCT-2003  vansub   Created
--                  : 19-NOV-2004  kdhulipa [Bug 3928270] Not able to delete an
--                                          end date from code mapping scrn.
--                  : 12-JUL-2005  kdhulipa R12 Enhancements
--                  : 18-May-2006  kdhulipa Bug 5226248 NOT ABLE TO REMOVE A CODE
--                                          CONVERSION FOR PARTY SITE
--                  : Dec-2007  gdeepika  Code conversion for supplier trade profile
--                  : 3/25/2008 gdeepika  Changed the duplicate check for supplier code conv.
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ozf_code_conversion_pvt';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvsccb.pls';
G_PARTY_ID     NUMBER;
G_ACCOUNT_ID   NUMBER;

PROCEDURE create_code_conversion
(
   p_api_version_number         IN          NUMBER,
   p_init_msg_list              IN          VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN          VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN          NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_code_conversion_tbl        IN          code_conversion_tbl_type,
   x_code_conversion_id_tbl     OUT NOCOPY  JTF_NUMBER_TABLE
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'create_code_conversion';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER;
   l_code_conversion_id        NUMBER;
   l_code_conversion_rec       code_conversion_rec_type;



BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_code_conversion_pvt;

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
           OZF_UTILITY_PVT.debug_message( 'No of records to be created'||p_code_conversion_tbl.count);
        END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name);
          -- Invoke validation procedures
          Validate_Code_Conversion(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_validation_mode        => JTF_PLSQL_API.G_CREATE,
                 p_code_conversion_tbl    => p_code_conversion_tbl,
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

      l_code_conversion_id     := NULL;
      l_object_version_number  := NULL;

      x_code_conversion_id_tbl := JTF_NUMBER_TABLE();

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
          OZF_UTILITY_PVT.debug_message( 'No of rows to be created '|| p_code_conversion_tbl.count);
        END IF;

      FOR i IN 1 .. p_code_conversion_tbl.count
      LOOP

        l_code_conversion_rec := p_code_conversion_tbl(i);

        IF (l_code_conversion_rec.org_id IS NULL)      THEN
             l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements
        ELSE
             l_org_id := l_code_conversion_rec.org_id;
        END IF;
        SELECT ozf_code_conversions_all_s.nextval INTO l_code_conversion_id FROM DUAL;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
            OZF_UTILITY_PVT.debug_message( 'l_org_id ' || l_org_id);
            OZF_UTILITY_PVT.debug_message( 'Code Conversion ID '|| l_code_conversion_id);
        END IF;

        BEGIN


         OZF_CODE_CONVERSION_PKG.Insert_Row(
          px_code_conversion_id     =>    l_code_conversion_id,
          px_object_version_number  =>    l_object_version_number,
          p_last_update_date        =>    SYSDATE,
          p_last_updated_by         =>    FND_GLOBAL.USER_ID,
          p_creation_date           =>    SYSDATE,
          p_created_by              =>    FND_GLOBAL.USER_ID,
          p_last_update_login       =>    FND_GLOBAL.CONC_LOGIN_ID,
          px_org_id                 =>    l_org_id,
          p_party_id                =>    l_code_conversion_rec.party_id,
          p_cust_account_id         =>    l_code_conversion_rec.cust_account_id,
          p_code_conversion_type    =>    l_code_conversion_rec.code_conversion_type,
          p_external_code           =>    l_code_conversion_rec.external_code,
          p_internal_code           =>    l_code_conversion_rec.internal_code,
          p_description             =>    l_code_conversion_rec.description,
          p_start_date_active       =>    nvl(l_code_conversion_rec.start_date_active,sysdate),
          p_end_date_active         =>    l_code_conversion_rec.end_date_active,
          p_attribute_category      =>    l_code_conversion_rec.attribute_category,
          p_attribute1              =>    l_code_conversion_rec.attribute1,
          p_attribute2              =>    l_code_conversion_rec.attribute2,
          p_attribute3              =>    l_code_conversion_rec.attribute3,
          p_attribute4              =>    l_code_conversion_rec.attribute4,
          p_attribute5              =>    l_code_conversion_rec.attribute5,
          p_attribute6              =>    l_code_conversion_rec.attribute6,
          p_attribute7              =>    l_code_conversion_rec.attribute7,
          p_attribute8              =>    l_code_conversion_rec.attribute8,
          p_attribute9              =>    l_code_conversion_rec.attribute9,
          p_attribute10             =>    l_code_conversion_rec.attribute10,
          p_attribute11             =>    l_code_conversion_rec.attribute11,
          p_attribute12             =>    l_code_conversion_rec.attribute12,
          p_attribute13             =>    l_code_conversion_rec.attribute13,
          p_attribute14             =>    l_code_conversion_rec.attribute14,
          p_attribute15             =>    l_code_conversion_rec.attribute15);

        EXCEPTION
          WHEN OTHERS THEN
              OZF_UTILITY_PVT.debug_message (SQLERRM ||'  Error in creating code conversion map');
              RAISE FND_API.G_EXC_ERROR;
        END;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' after insert call - code conversion id' || l_code_conversion_id);
           OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' after insert call - obj version no ' || l_code_conversion_rec.Object_Version_Number);
        END IF;

      x_code_conversion_id_tbl.extend;
      x_code_conversion_id_tbl(x_code_conversion_id_tbl.count) :=  l_code_conversion_id;

   end loop;

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
     ROLLBACK TO create_code_conversion_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_code_conversion_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
  WHEN OTHERS THEN
     ROLLBACK TO create_code_conversion_pvt;
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

END create_code_conversion ;


PROCEDURE Update_code_conversion
(
    p_api_version_number         IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_code_conversion_tbl        IN          code_conversion_tbl_type  ,
    x_object_version_number      OUT NOCOPY  JTF_NUMBER_TABLE
    )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Update_code_conversion';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_object_version_number   NUMBER;

  l_code_conversion_id  NUMBER;

  CURSOR csr_code_conversion(cv_code_conversion_id NUMBER)
  IS
  SELECT  code_conversion_id,
         object_version_number,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         org_id,
         party_id,
         cust_account_id,
         code_conversion_type,
         external_code,
         internal_code,
         description,
         start_date_active,
         end_date_active,
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
 FROM    ozf_code_conversions_all
 WHERE   code_conversion_id = cv_code_conversion_id;

 CURSOR get_org
 IS
 SELECT org_id FROM ozf_sys_parameters;

l_code_conversion_rec   code_conversion_rec_type;
l_code_conversion_tbl   code_conversion_tbl_type;
l_org_id                NUMBER;
p_code_conversion_rec   code_conversion_rec_type;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_code_conversion_pvt;

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

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('p_code_conversion_tbl(1).description: ' || p_code_conversion_tbl(1).description );
      END IF;

      FOR i in 1 .. p_code_conversion_tbl.count
      LOOP
        p_code_conversion_rec := p_code_conversion_tbl(i);
        l_code_conversion_id  := p_code_conversion_rec.code_conversion_id;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'Code Conversion ID' || l_code_conversion_id);
        END IF;

      --  Check for the existance of the record
        OPEN csr_code_conversion(l_code_conversion_id);
        FETCH csr_code_conversion
        INTO   l_code_conversion_rec.code_conversion_id
              ,l_code_conversion_rec.object_version_number
              ,l_code_conversion_rec.last_update_date
              ,l_code_conversion_rec.last_updated_by
              ,l_code_conversion_rec.creation_date
              ,l_code_conversion_rec.created_by
              ,l_code_conversion_rec.last_update_login
              ,l_code_conversion_rec.org_id
              ,l_code_conversion_rec.party_id
              ,l_code_conversion_rec.cust_account_id
              ,l_code_conversion_rec.code_conversion_type
              ,l_code_conversion_rec.external_code
              ,l_code_conversion_rec.internal_code
              ,l_code_conversion_rec.description
              ,l_code_conversion_rec.start_date_active
              ,l_code_conversion_rec.end_date_active
              ,l_code_conversion_rec.attribute_category
              ,l_code_conversion_rec.attribute1
              ,l_code_conversion_rec.attribute2
              ,l_code_conversion_rec.attribute3
              ,l_code_conversion_rec.attribute4
              ,l_code_conversion_rec.attribute5
              ,l_code_conversion_rec.attribute6
              ,l_code_conversion_rec.attribute7
              ,l_code_conversion_rec.attribute8
              ,l_code_conversion_rec.attribute9
              ,l_code_conversion_rec.attribute10
              ,l_code_conversion_rec.attribute11
              ,l_code_conversion_rec.attribute12
              ,l_code_conversion_rec.attribute13
              ,l_code_conversion_rec.attribute14
              ,l_code_conversion_rec.attribute15
              ,l_code_conversion_rec.security_group_id;

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
              OZF_UTILITY_PVT.debug_message('Existing description '|| l_code_conversion_rec.description);
           END IF;

         IF ( csr_code_conversion%NOTFOUND) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
              OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'nodata for upd');
            END IF;

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
              FND_MSG_PUB.add;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
        CLOSE csr_code_conversion;


        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
          OZF_UTILITY_PVT.debug_message( 'Pre Object Version Number ' || l_code_conversion_rec.object_version_number);
          OZF_UTILITY_PVT.debug_message( 'Post Object Version Number' || P_code_conversion_rec.object_version_number);
        END IF;

      --- Check the Version Number for Locking
        IF l_code_conversion_rec.object_version_number <> P_code_conversion_rec.Object_Version_number
        THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
               OZF_UTILITY_PVT.debug_message( 'dbver' || l_code_conversion_rec.object_version_number);
               OZF_UTILITY_PVT.debug_message( 'reqver' || P_code_conversion_rec.object_version_number);
            END IF;

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
             FND_MESSAGE.Set_Name('OZF', 'OZF_API_RESOURCE_LOCKED');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

     -- Update internal code only when it is NUll
        IF l_code_conversion_rec.internal_code IS NOT NULL  AND
           l_code_conversion_rec.internal_code <> P_code_conversion_rec.internal_code
        THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_CODE_CONV_UPD_INTLCODE');
              FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'Existing End Date' || l_code_conversion_rec.End_Date_Active);
           OZF_UTILITY_PVT.debug_message( 'Updated End Date' || p_code_conversion_rec.End_Date_Active);
        END IF;

     -- Update End date only when it is NUll or a future date
        IF  trunc(nvl(l_code_conversion_Rec.End_Date_Active,sysdate+1)) <= TRUNC(SYSDATE)
        AND
            Trunc(l_code_conversion_Rec.End_Date_Active) <> Trunc(P_code_conversion_Rec.End_Date_Active)
        THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_CODE_CONV_UPD_ENDDATE');
              FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'Existing Start Date' || l_code_conversion_rec.Start_Date_Active);
           OZF_UTILITY_PVT.debug_message( 'Updated Start Date' || p_code_conversion_rec.Start_Date_Active);
        END IF;

     ---Update not allowed for  Start Date when start date is earlier than current date
        IF  trunc(l_code_conversion_Rec.Start_Date_Active)
        <> trunc(P_code_conversion_Rec.Start_Date_Active)
        THEN
            IF p_code_conversion_Rec.Start_Date_Active < TRUNC(SYSDATE)
            THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                FND_MESSAGE.Set_Name('OZF', 'OZF_CODE_CONV_UPD_STARTDATE');
                FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF  l_code_conversion_Rec.end_date_active <  p_code_conversion_Rec.Start_Date_Active THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                OZF_UTILITY_PVT.debug_message ('Cannot update an end dated code conversion map');
              END IF;
              raise FND_API.G_EXC_ERROR;
            END IF;

       END IF;

     -- Update not allowed for External Code
        IF l_code_conversion_Rec.external_Code <> P_code_conversion_Rec.external_Code
        THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_CODE_CONV_UPD_EXTCD');
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
            Validate_Code_Conversion(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_validation_mode        => JTF_PLSQL_API.G_UPDATE,
            p_code_conversion_tbl    => p_code_conversion_tbl,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);
        END IF;

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_code_conversion_rec.org_id IS NULL) THEN
            l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements
        ELSE
           l_org_id := l_code_conversion_rec.org_id;
        END IF;


     -- Call Update Table Handler
     -- Debug Message
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'Private API: Calling Update table handler');
        END IF;
        BEGIN
           OZF_CODE_CONVERSION_PKG.Update_Row(
           p_code_conversion_id     =>    l_code_conversion_id,
           p_object_version_number  =>     p_code_conversion_rec.object_version_number,
           p_last_update_date       =>     SYSDATE,
           p_last_updated_by        =>     FND_GLOBAL.USER_ID,
           p_last_update_login      =>     FND_GLOBAL.CONC_LOGIN_ID,
           p_org_id                 =>     l_org_id,
           p_party_id               =>     p_code_conversion_rec.party_id,
           p_cust_account_id        =>     p_code_conversion_rec.cust_account_id,
           p_code_conversion_type   =>     p_code_conversion_rec.code_conversion_type,
           p_external_code          =>     p_code_conversion_rec.external_code,
           p_internal_code          =>     p_code_conversion_rec.internal_code,
           p_description            =>     p_code_conversion_rec.description,
           p_start_date_active      =>     p_code_conversion_rec.start_date_active,
           p_end_date_active        =>     p_code_conversion_rec.end_date_active,
           p_attribute_category     =>     p_code_conversion_rec.attribute_category,
           p_attribute1             =>     p_code_conversion_rec.attribute1,
           p_attribute2             =>     p_code_conversion_rec.attribute2,
           p_attribute3             =>     p_code_conversion_rec.attribute3,
           p_attribute4             =>     p_code_conversion_rec.attribute4,
           p_attribute5             =>     p_code_conversion_rec.attribute5,
           p_attribute6             =>     p_code_conversion_rec.attribute6,
           p_attribute7             =>     p_code_conversion_rec.attribute7,
           p_attribute8             =>     p_code_conversion_rec.attribute8,
           p_attribute9             =>     p_code_conversion_rec.attribute9,
           p_attribute10            =>     p_code_conversion_rec.attribute10,
           p_attribute11            =>     p_code_conversion_rec.attribute11,
           p_attribute12            =>     p_code_conversion_rec.attribute12,
           p_attribute13            =>     p_code_conversion_rec.attribute13,
           p_attribute14            =>     p_code_conversion_rec.attribute14,
           p_attribute15            =>     p_code_conversion_rec.attribute15);



        EXCEPTION
           WHEN OTHERS THEN
             OZF_UTILITY_PVT.debug_message (SQLERRM ||'  Error in updating code conversion map');
             RAISE FND_API.G_EXC_ERROR;
        END;

        x_object_version_number.EXTEND;
        x_object_Version_number(x_object_version_number.count) := p_code_conversion_rec.Object_Version_Number;

     END LOOP;


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
    ROLLBACK TO update_code_conversion_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_code_conversion_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO update_code_conversion_pvt;
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

END Update_Code_Conversion;



PROCEDURE Update_Code_Conversion_Tbl(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    P_code_conversion_Tbl        IN  code_conversion_tbl_type
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'update_code_conversion_tbl';
l_api_version_number      CONSTANT NUMBER   := 1.0;

p_code_conversion_rec     code_conversion_rec_type;

l_code_conversion_id      NUMBER;
v_code_conversion_id      JTF_NUMBER_TABLE;
v_object_version_number   JTF_NUMBER_TABLE;

l_create_flag             VARCHAR2(10);

l_create_code_conv_tbl    code_conversion_tbl_type := code_conversion_tbl_type();
l_update_code_conv_tbl    code_conversion_tbl_type := code_conversion_tbl_type();

l_cc_cnt                  NUMBER := 0;
l_up_cnt                  NUMBER := 0;

BEGIN
      -- Standard Start of API savepoint
     SAVEPOINT update_code_conversion_tbl_pvt;

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
         OZF_UTILITY_PVT.debug_message('Total Number of records '||P_code_conversion_Tbl.count);
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      v_code_conversion_id    :=   JTF_NUMBER_TABLE();
      v_object_version_number :=   JTF_NUMBER_TABLE();

      FOR i IN P_code_conversion_Tbl.first .. P_code_conversion_Tbl.last
      LOOP

          l_code_conversion_id := P_code_conversion_Tbl(i).code_conversion_id;
          P_code_conversion_Rec := P_code_conversion_Tbl(i);

          -- Fix for 3928270

          -- IF p_code_conversion_rec.end_date_active = FND_API.g_miss_date
          -- THEN
             -- p_code_conversion_rec.end_date_active := NULL;
          -- END IF;


         IF l_code_conversion_id IS NULL OR l_code_conversion_id  = -1   then
             l_cc_cnt := l_cc_cnt + 1;

             l_create_code_conv_tbl.extend;
             l_create_code_conv_tbl(l_cc_cnt) := P_code_conversion_Rec;

          ELSE
             l_up_cnt := l_up_cnt + 1;

             l_update_code_conv_tbl.extend;
             l_update_code_conv_tbl(l_up_cnt) := P_code_conversion_Rec;
          END IF;

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
             OZF_UTILITY_PVT.debug_message('End Date '||P_code_conversion_Rec.end_date_active);
          END IF;

      END LOOP;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('No of rows to be created: ' || l_cc_cnt);
         OZF_UTILITY_PVT.debug_message('No of rows to be updated: ' || l_up_cnt);
      END IF;

      IF  l_cc_cnt > 0 THEN
             --- Call to Create Procedure
             Create_Code_Conversion
             (
                p_api_version_number         =>  p_api_version_number,
                p_init_msg_list              =>  p_init_msg_list,
                p_commit                     =>  p_commit,
                p_validation_level           =>  p_validation_level,
                x_return_status              =>  x_return_Status,
                x_msg_count                  =>  x_msg_Count,
                x_msg_data                   =>  x_msg_Data,
                p_code_conversion_tbl        =>  l_create_code_conv_tbl,
                x_code_conversion_id_tbl           =>  v_code_conversion_id
              );

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
      END IF;

      IF l_up_cnt > 0 THEN
              -- Call to Update Procedure
            Update_code_conversion (
               p_api_version_number         =>  p_api_version_number ,
               p_init_msg_list              =>  p_init_msg_list,
               p_commit                     =>  p_commit,
               p_validation_level           =>  p_validation_level,
               x_return_status              =>  x_return_Status,
               x_msg_count                  =>  x_msg_Count,
               x_msg_data                   =>  x_msg_Data,
               p_code_conversion_tbl        =>  l_update_code_conv_tbl,
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
    ROLLBACK TO update_code_conversion_tbl_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_code_conversion_tbl_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO update_code_conversion_tbl_pvt;
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


END Update_Code_Conversion_Tbl;


PROCEDURE Delete_Code_Conversion_Tbl
(
    p_api_version_number         IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_code_conversion_tbl        IN  code_conversion_Tbl_Type
    )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'delete_code_conversion_tbl';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

  p_code_conversion_rec     code_conversion_rec_type;

  l_code_conversion_id      NUMBER;
  l_object_version_number   NUMBER;


BEGIN
      -- Standard Start of API savepoint
     SAVEPOINT delete_code_conversion_tbl_pvt;

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
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      FOR i IN P_code_conversion_Tbl.first .. P_code_conversion_Tbl.last
      LOOP

          l_code_conversion_id := P_code_conversion_Tbl(i).code_conversion_id;
          l_object_version_number := P_code_conversion_Tbl(i).object_version_number;

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
             OZF_UTILITY_PVT.debug_message('Code Conversion ID ' || l_code_conversion_id);
             OZF_UTILITY_PVT.debug_message('Object Version Number ' || l_object_version_number);
          END IF;

          IF  l_object_version_number IS NULL
          OR l_code_conversion_id IS NULL THEN

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
                OZF_UTILITY_PVT.debug_message('In If block');
             END IF;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_REQ_PARAMETERS_MISSING');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


         ELSE

            IF   P_code_conversion_Tbl(i).party_id IS NOT NULL THEN
               G_PARTY_ID :=  P_code_conversion_Tbl(i).party_id;
            ELSE
               G_PARTY_ID := NULL;
            END IF;
            IF   P_code_conversion_Tbl(i).cust_account_id IS NOT NULL THEN
               G_ACCOUNT_ID :=  P_code_conversion_Tbl(i).cust_account_id;
            ELSE
               G_ACCOUNT_ID := NULL;
            END IF;

           Delete_Code_Conversion(
             p_api_version_number        => 1.0,
             p_init_msg_list             => FND_API.G_FALSE,
             p_commit                    => FND_API.G_FALSE,
             p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
             x_return_status             => X_Return_Status ,
             x_msg_count                 => X_Msg_Count ,
             x_msg_data                  => X_Msg_Data ,
             p_code_conversion_id        => l_code_conversion_id,
             p_object_version_number     => l_object_version_number,
             p_external_code             => P_code_conversion_Tbl(i).external_code ,
             p_code_conversion_type      => P_code_conversion_Tbl(i).code_conversion_type);


            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

       END IF;

     END LOOP;


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
    ROLLBACK TO delete_code_conversion_tbl_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_code_conversion_tbl_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO delete_code_conversion_tbl_pvt;
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


END Delete_Code_Conversion_Tbl;




PROCEDURE Delete_Code_Conversion
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_code_conversion_id         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_external_code              IN   VARCHAR2,
    p_code_conversion_type       IN   VARCHAR2
    )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Delete_code_conversion';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_object_version_number   NUMBER;

  l_dummy                   NUMBER;
  l_acc_dummy               NUMBER;
  l_party_id                NUMBER;
  l_account_id              NUMBER;

  TYPE case_chk_cur  IS REF CURSOR;
  csr_code_conv_party       case_chk_cur;
  csr_code_conv_location    case_chk_cur;
  csr_code_conv_uom         case_chk_cur;

  l_sql                     VARCHAR2(32000);
  l_where                   VARCHAR2(32000);
  l_interface_sql           VARCHAR2(32000);

  CURSOR csr_code_conv_reason (cv_external_code VARCHAR2) IS
  SELECT COUNT(customer_reason)
  FROM   ozf_claims
  WHERE  customer_reason = cv_external_code;


  CURSOR csr_code_conv_product_pt (cv_external_code VARCHAR2
                                  ,cv_party_id      NUMBER
                                  ,cv_account_id    NUMBER) IS
  SELECT MAX(pt_cnt)
  FROM (
     SELECT  COUNT(orig_system_item_number) pt_cnt
     FROM   ozf_resale_lines_int lin
           ,ozf_resale_batches bat
     WHERE  lin.resale_batch_id = bat.resale_batch_id
       AND  orig_system_item_number = cv_external_code
       AND  (bat.partner_party_id   = cv_party_id OR bat.partner_cust_account_id = cv_account_id)
     UNION
    SELECT  COUNT(orig_system_item_number)  pt_cnt
     FROM   ozf_resale_lines lin
          ,ozf_resale_batches bat
          ,ozf_resale_batch_line_maps map
    WHERE  orig_system_item_number = cv_external_code
      AND  lin.resale_line_id = map.resale_line_id
      AND  bat.resale_batch_id = map.resale_batch_id
      AND  (bat.partner_party_id   = cv_party_id OR bat.partner_cust_account_id = cv_account_id) ) x;


  CURSOR csr_code_conv_product (cv_external_code VARCHAR2)
  IS
  SELECT COUNT(orig_system_item_number)
  FROM   ozf_resale_lines_int lin
  WHERE  orig_system_item_number = cv_external_code;

  CURSOR csr_code_conv_agreement_pt (cv_external_code VARCHAR2
                                    ,cv_party_id NUMBER
                                    ,cv_account_id    NUMBER)
  IS
  SELECT MAX(pt_cnt)
  FROM
  (
   SELECT  COUNT(orig_system_agreement_name) pt_cnt
   FROM   ozf_resale_lines_int lin
         ,ozf_resale_batches bat
   WHERE  lin.resale_batch_id = bat.resale_batch_id
     AND  orig_system_agreement_name = cv_external_code
     AND  (bat.partner_party_id   = cv_party_id OR bat.partner_cust_account_id = cv_account_id)
   UNION
   SELECT  COUNT(orig_system_agreement_name)  pt_cnt
     FROM ozf_resale_adjustments lin
          ,ozf_resale_batches bat
    WHERE  orig_system_agreement_name = cv_external_code
      AND  bat.resale_batch_id = lin.resale_batch_id
     AND  (bat.partner_party_id   = cv_party_id OR bat.partner_cust_account_id = cv_account_id) ) x;

  CURSOR csr_code_conv_agreement (cv_external_code VARCHAR2) IS
  SELECT COUNT(orig_system_agreement_name)
  FROM   ozf_resale_lines_int lin
  WHERE  orig_system_agreement_name = cv_external_code;

  CURSOR csr_code_conv_agrmt_uom (cv_external_code VARCHAR2
                                 ,cv_party_id NUMBER
                                 ,cv_account_id NUMBER ) IS
  SELECT COUNT(orig_system_agreement_uom)
  FROM   ozf_resale_adjustments lin
        ,ozf_resale_batches bat
    WHERE  orig_system_agreement_uom = cv_external_code
      AND  bat.resale_batch_id = lin.resale_batch_id
     AND  (bat.partner_party_id   = cv_party_id OR bat.partner_cust_account_id = cv_account_id) ;

  CURSOR csr_code_conv_agmt_uom (cv_external_code VARCHAR2 ) IS
  SELECT COUNT(orig_system_agreement_uom)
  FROM   ozf_resale_adjustments lin
  WHERE  orig_system_agreement_uom = cv_external_code;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_code_conversion_pvt;

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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Validate the Delete Condition
      --

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('Party ID in delete code conersion: ' || l_party_id);
      END IF;
      IF p_external_code IS NOT NULL  THEN

         IF p_code_conversion_type = 'OZF_REASON_CODES' THEN

            l_dummy := null;

            OPEN  csr_code_conv_reason (p_external_code);
            FETCH csr_code_conv_reason  INTO  l_dummy;
            CLOSE csr_code_conv_reason;

            IF l_dummy <> 0 Then
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_RSNMAP_DELETE');
                  FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

        ELSIF p_code_conversion_type = 'OZF_UOM_CODES' THEN

          l_dummy := null;
          l_sql := 'SELECT ( CASE WHEN orig_system_uom =  :1  THEN 1'||
                   '              WHEN orig_system_purchase_uom = :1  THEN 1 ';
           l_where := '            (orig_system_uom = :1 '||
                      '           OR orig_system_purchase_uom = :1 ';

           l_interface_sql := l_sql ||'         WHEN orig_system_agreement_uom :1 THEN 1';
           l_sql :=  l_sql||'                ELSE 0  END ) pt_cnt'|| ' FROM            ';
           l_interface_sql := l_interface_sql || l_sql;



          IF  G_PARTY_ID IS NOT NULL THEN

           l_sql :=  l_sql||'ozf_resale_batches bat, ozf_resale_lines lin ,ozf_resale_batch_line_maps map ';
           l_sql :=  l_sql||'WHERE  lin.resale_line_id = map.resale_line_id  ';
           l_sql :=  l_sql||'AND map.resale_batch_id = bat.resale_batch_id ';
           l_sql :=  l_sql|| 'AND '||l_where ||') ';

           l_interface_sql    := l_sql ||'ozf_resale_batches bat, ozf_resale_lines_int lin '||
                                         ' WHERE lin.resale_batch_id = bat.resale_batch_id  ';
           l_interface_sql    := l_interface_sql ||' AND '||l_where || 'OR orig_system_agreement_uom = :1 )';


              l_sql            := l_sql||'             AND bat.partner_party_id = :2 ' ;
              l_interface_sql  := l_interface_sql||'             AND bat.partner_party_id = :2' ;

             IF   G_ACCOUNT_ID IS NOT NULL THEN
                 l_sql := l_sql ||' AND  bat.partner_cust_account_id = :3 ' ;
                 l_interface_sql := l_sql ||'AND  bat.partner_cust_account_id = :3 ';
             END IF;


          ELSIF  G_PARTY_ID IS NULL AND G_ACCOUNT_ID IS NULL THEN
             l_sql := l_sql ||' ozf_resale_lines   WHERE';
             l_interface_sql := l_sql ||' ozf_resale_lines_int   WHERE ';
             l_sql := l_sql || l_where ||') ';
             l_interface_sql    := l_interface_sql ||l_where ||
                                   'OR orig_system_agreement_uom = :1 )';

          END IF;

          for i in 1..ceil((length(l_sql)/100)) loop
            IF fnd_msg_pub.Check_Msg_Level      (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               OZF_UTILITY_PVT.debug_message(substr(l_sql, (i-1)*100+1, 100));
            END IF;
          end loop;
             IF g_party_id IS NULL THEN
                OPEN csr_code_conv_uom FOR l_sql USING p_external_code
                                                        ,p_external_code
                                                        ,p_external_code
                                                        ,p_external_code;
             ELSIF g_party_id IS NOT NULL AND g_account_id IS NOT NULL THEN

               OPEN csr_code_conv_uom FOR l_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id
                                                       ,g_account_id;
            ELSIF g_party_id IS NOT NULL AND g_account_id IS NULL THEN
               OPEN csr_code_conv_uom FOR l_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id;
            END IF;
          FETCH csr_code_conv_uom INTO l_dummy;
          CLOSE csr_code_conv_uom;
          IF l_dummy = 0 THEN
             IF g_party_id IS NULL THEN
                OPEN csr_code_conv_uom FOR l_interface_sql USING p_external_code
                                                        ,p_external_code
                                                        ,p_external_code
                                                        ,p_external_code
                                                        ,p_external_code
                                                        ,p_external_code;
             ELSIF g_party_id IS NOT NULL AND g_account_id IS NOT NULL THEN

               OPEN csr_code_conv_uom FOR l_interface_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id
                                                       ,g_account_id;
            ELSIF g_party_id IS NOT NULL AND g_account_id IS NULL THEN
               OPEN csr_code_conv_uom FOR l_interface_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id;
            END IF;

             FETCH csr_code_conv_uom INTO l_dummy;
             CLOSE csr_code_conv_uom;
          END IF;
          IF l_dummy <> 0 THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('OZF', 'OZF_RESALE_UOM_DELETE');
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            IF g_party_id IS NOT NULL  THEN
               OPEN csr_code_conv_agrmt_uom ( p_external_code
                                             ,g_party_id
                                             ,g_account_id );
               FETCH  csr_code_conv_agrmt_uom INTO  l_dummy;
               CLOSE  csr_code_conv_agrmt_uom;

               IF l_dummy <> 0 THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('OZF', 'OZF_RESALE_UOM_DELETE');
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            ELSE
               OPEN csr_code_conv_agmt_uom ( p_external_code);
               FETCH  csr_code_conv_agmt_uom INTO  l_dummy;
               CLOSE  csr_code_conv_agmt_uom;

               IF l_dummy <> 0 THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('OZF', 'OZF_RESALE_UOM_DELETE');
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;
          END IF;



        ELSIF p_code_conversion_type = 'OZF_AGREEMENT_CODES' THEN

            l_dummy := null;
           IF G_PARTY_ID IS NOT NULL OR G_ACCOUNT_ID IS NOT NULL THEN
              OPEN  csr_code_conv_agreement_pt (p_external_code
                                              , g_party_id
                                              , g_account_id);
              FETCH csr_code_conv_agreement_pt INTO    l_dummy;
              CLOSE csr_code_conv_agreement_pt;

              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
                 OZF_UTILITY_PVT.debug_message('l_dummy in delete code conersion: ' || l_dummy);
              END IF;
           END IF;
           IF  G_PARTY_ID IS NULL AND G_ACCOUNT_ID IS NULL THEN
               OPEN  csr_code_conv_agreement (p_external_code);
               FETCH csr_code_conv_agreement INTO  l_dummy;
               CLOSE csr_code_conv_agreement;
           END IF;
           IF l_dummy <> 0  THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('OZF', 'OZF_RESALE_AGREEMENT_DELETE');
                 FND_MSG_PUB.ADD;
              END IF;
              raise FND_API.G_EXC_ERROR;
           END IF;
        ELSIF p_code_conversion_type = 'OZF_PRODUCT_CODES' THEN
            l_dummy := null;
--          Delete from Trade Profile at Party or Account level
           IF G_PARTY_ID IS NOT NULL OR G_ACCOUNT_ID IS NOT NULL THEN

             OPEN  csr_code_conv_product_pt (p_external_code
                                            ,g_party_id
                                            ,g_account_id);
             FETCH csr_code_conv_product_pt INTO  l_dummy;
             CLOSE csr_code_conv_product_pt;
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
                OZF_UTILITY_PVT.debug_message('l_dummy in delete code conersion: ' || l_dummy);
             END IF;
           END IF;
--          Delete from site Profile
           IF  G_PARTY_ID IS NULL AND G_ACCOUNT_ID IS NULL THEN
               OPEN  csr_code_conv_product (p_external_code);
               FETCH csr_code_conv_product INTO  l_dummy;
               CLOSE csr_code_conv_product;
           END IF;
           IF l_dummy <> 0  THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('OZF', 'OZF_RESALE_PRODUCT_DELETE');
                    FND_MSG_PUB.ADD;
              END IF;
              raise FND_API.G_EXC_ERROR;
           END IF;
       ELSIF   p_code_conversion_type = 'OZF_PARTY_CODES' THEN
            l_dummy := null;
--      Make this cursor static when application is upgraded to 9i


          l_sql := 'SELECT ( CASE WHEN bill_to_party_name =  :1  THEN 1'||
                   '                     WHEN ship_to_party_name = :1  THEN 1 '||
                   '         ELSE 0  END ) pt_cnt'||
                   ' FROM            ';
          l_where := '            (bill_to_party_name = :1 '||
                     '          OR ship_to_party_name = :1  )';


          IF  G_PARTY_ID IS NOT NULL THEN
             l_sql :=  l_sql||'ozf_resale_batches bat, ozf_resale_lines lin ,ozf_resale_batch_line_maps map ';
             l_sql :=  l_sql||'WHERE  lin.resale_line_id = map.resale_line_id  ';
             l_sql :=  l_sql||'AND map.resale_batch_id = bat.resale_batch_id ';

             l_where :=  l_where||'              AND bat.partner_party_id =  :2 ' ;

             IF   G_ACCOUNT_ID IS NOT NULL THEN
                 l_where := l_where||' AND  bat.partner_cust_account_id = :3 ' ;
             END IF;

             l_sql := l_sql || 'AND '||l_where;
             l_interface_sql := l_interface_sql ||'AND '|| l_where;

          ELSIF  G_PARTY_ID IS NULL AND G_ACCOUNT_ID IS NULL THEN
             l_sql := l_sql ||' ozf_resale_lines   WHERE';
             l_interface_sql := l_sql ||' ozf_resale_lines_int   WHERE ';
             l_sql := l_sql || l_where;
             l_interface_sql := l_interface_sql || l_where;
          END IF;
          for i in 1..ceil((length(l_sql)/100)) loop
            IF fnd_msg_pub.Check_Msg_Level      (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               OZF_UTILITY_PVT.debug_message(substr(l_sql, (i-1)*100+1, 100));
            END IF;
          end loop;
          IF g_party_id IS NULL THEN
             OPEN csr_code_conv_party FOR l_sql USING p_external_code
                                                     ,p_external_code
                                                     ,p_external_code
                                                     ,p_external_code;
          ELSIF g_party_id IS NOT NULL AND g_account_id IS NOT NULL THEN

               OPEN csr_code_conv_party FOR l_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id
                                                     ,g_account_id;
          ELSIF g_party_id IS NOT NULL AND g_account_id IS NULL THEN
               OPEN csr_code_conv_party FOR l_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id;
          END IF;
          FETCH csr_code_conv_party INTO l_dummy;
          CLOSE csr_code_conv_party;
          IF l_dummy = 0 THEN
             IF g_party_id IS NULL THEN
                OPEN csr_code_conv_party FOR l_interface_sql USING p_external_code
                                                        ,p_external_code
                                                        ,p_external_code
                                                        ,p_external_code;
             ELSIF g_party_id IS NOT NULL AND g_account_id IS NOT NULL THEN

               OPEN csr_code_conv_party FOR l_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id
                                                      ,g_account_id;
             ELSIF g_party_id IS NOT NULL AND g_account_id IS NULL THEN
               OPEN csr_code_conv_party FOR l_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id;
             END IF;
             FETCH csr_code_conv_party INTO l_dummy;
             CLOSE csr_code_conv_party;
          END IF;
          IF l_dummy <> 0 THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('OZF', 'OZF_RESALE_PARTY_DELETE');
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;


     ELSIF   p_code_conversion_type = 'OZF_PARTY_SITE_CODES' THEN


          l_sql := 'SELECT ( CASE WHEN bill_to_location =  :1  THEN 1'||
                   '                     WHEN ship_to_location = :1  THEN 1 '||
                   '                ELSE 0  END ) pt_cnt'||
                   ' FROM            ';
          l_where := '            (bill_to_location = :1 '||
                     '          OR ship_to_location = :1 )';

          -- fix for 5226248
          IF  G_PARTY_ID IS NOT NULL THEN
             l_sql :=  l_sql||'ozf_resale_batches bat, ozf_resale_lines lin ,ozf_resale_batch_line_maps map ';
             l_interface_sql    := l_sql ||'ozf_resale_batches bat, ozf_resale_lines_int lin '||
                                          ' WHERE lin.resale_batch_id = bat.resale_batch_id  ';
             l_sql :=  l_sql||'WHERE  lin.resale_line_id = map.resale_line_id  ';
             l_sql :=  l_sql||'AND map.resale_batch_id = bat.resale_batch_id ';

             l_where :=  l_where ||'              AND bat.partner_party_id =  :2' ;

             IF   G_ACCOUNT_ID IS NOT NULL THEN
                 l_where := l_where||' AND  bat.partner_cust_account_id = :3 ' ;
             END IF;

             l_sql := l_sql || 'AND '||l_where;
             l_interface_sql := l_interface_sql || 'AND '||l_where;

          ELSIF  G_PARTY_ID IS NULL AND G_ACCOUNT_ID IS NULL THEN
             l_interface_sql := l_sql ||' ozf_resale_lines_int   WHERE ';
             l_sql := l_sql ||' ozf_resale_lines   WHERE';
             l_sql := l_sql || l_where;
             l_interface_sql := l_interface_sql || l_where;
          END IF;

          IF g_party_id IS NULL THEN
                OPEN csr_code_conv_party FOR l_interface_sql USING p_external_code
                                                        ,p_external_code
                                                        ,p_external_code
                                                        ,p_external_code;
          ELSIF g_party_id IS NOT NULL AND g_account_id IS NOT NULL THEN

               OPEN csr_code_conv_party FOR l_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id
                                                      ,g_account_id;
          ELSIF g_party_id IS NOT NULL AND g_account_id IS NULL THEN
               OPEN csr_code_conv_party FOR l_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id;
          END IF;
          FETCH csr_code_conv_party INTO l_dummy;
          CLOSE csr_code_conv_party;
          IF l_dummy = 0 THEN
             IF g_party_id IS NULL THEN
                OPEN csr_code_conv_party FOR l_sql USING p_external_code
                                                        ,p_external_code
                                                        ,p_external_code
                                                        ,p_external_code;

             ELSIF g_party_id IS NOT NULL AND g_account_id IS NOT NULL THEN

               OPEN csr_code_conv_party FOR l_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id
                                                      ,g_account_id;
             ELSIF g_party_id IS NOT NULL AND g_account_id IS NULL THEN
               OPEN csr_code_conv_party FOR l_sql USING p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,p_external_code
                                                       ,g_party_id;
             END IF;
             FETCH csr_code_conv_party INTO l_dummy;
             CLOSE csr_code_conv_party;
          END IF;
          IF l_dummy <> 0 THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('OZF', 'OZF_RESALE_PARTY_SITE_DELETE');
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
    END IF;   -- p_code_conversion_type

  END IF;      -- p_external_code is not null

      -- Api body
      --
      -- Debug Message
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      BEGIN
         OZF_CODE_CONVERSION_PKG.Delete_Row( p_code_conversion_id     => p_code_conversion_id,
                                             p_object_version_number  => p_object_version_number );
      EXCEPTION
         WHEN OTHERS THEN
              RAISE FND_API.G_EXC_ERROR;
      END;

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
    ROLLBACK TO delete_code_conversion_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_code_conversion_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO delete_code_conversion_pvt;
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

END Delete_Code_Conversion;

PROCEDURE Check_uniq_code_conversion(
    p_code_conversion_rec       IN    code_conversion_rec_type,
    p_validation_mode           IN    VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY   VARCHAR2
)
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Check_uniq_code_conversion';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

   CURSOR csr_code_conv_4party(cv_party_id NUMBER
                             , cv_external_code VARCHAR2
                             , cv_start_date_active DATE
                             , cv_end_date_active DATE)
   IS
      SELECT COUNT(party_id)
      FROM   ozf_code_conversions
      WHERE  party_id =  cv_party_id
      AND    UPPER(external_code) LIKE UPPER(cv_external_code)
      AND    TRUNC(start_date_active) <= TRUNC(NVL(cv_start_date_active,SYSDATE))
      AND    TRUNC(NVL(end_date_active,NVL(cv_end_date_active,SYSDATE)+1)) >= TRUNC(NVL(cv_end_date_active,SYSDATE))
      AND    TRUNC(NVL(end_date_active,NVL(cv_start_date_active,SYSDATE)+1)) >= TRUNC(NVL(cv_start_date_active,SYSDATE))
      AND    cust_account_id IS NULL;

   CURSOR csr_code_conv_4acct(cv_cust_account_id NUMBER
                             ,cv_external_code VARCHAR2
                             ,cv_start_date_active DATE
                             ,cv_end_date_active DATE)
   IS
      SELECT COUNT(cust_account_id)
      FROM   ozf_code_conversions
      WHERE  cust_account_id =  cv_cust_account_id
      AND    UPPER(external_code) LIKE UPPER(cv_external_code)
      AND    TRUNC(start_date_active) <= TRUNC(NVL(cv_start_date_active,SYSDATE))
      AND    TRUNC(NVL(end_date_active,NVL(cv_start_date_active,SYSDATE)+1)) >= TRUNC(NVL(cv_start_date_active,SYSDATE))
      AND    TRUNC(NVL(end_date_active,NVL(cv_end_date_active,SYSDATE)+1)) >= TRUNC(NVL(cv_end_date_active,SYSDATE));

   CURSOR csr_code_conv_4org(cv_external_code VARCHAR2,
                             cv_start_date_active DATE,
                             cv_end_date_active DATE
                            )
   IS
     SELECT COUNT(external_code)
     FROM   ozf_code_conversions
     WHERE    UPPER(external_code) LIKE UPPER(cv_external_code)
     AND    TRUNC(start_date_active) <= TRUNC(NVL(cv_start_date_active,SYSDATE))
     AND    TRUNC(NVL(end_date_active,NVL(cv_start_date_active,SYSDATE)+1)) >= TRUNC(NVL(cv_start_date_active,SYSDATE))
     AND    TRUNC(NVL(end_date_active,NVL(cv_end_date_active,SYSDATE)+1)) >= TRUNC(NVL(cv_end_date_active,SYSDATE))
     AND    party_id IS NULL
     AND    cust_account_id IS NULL;


   l_party_dummy        NUMBER;
   l_acct_dummy         NUMBER;
   l_valid_flag         VARCHAR2(30);
   l_org_dummy          NUMBER := 0;
   l_external_code      VARCHAR2(30);


BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message('in '||l_api_name);
      OZF_UTILITY_PVT.debug_message('Dummy value ' || l_org_dummy);
   END IF;
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_code_conversion_rec.cust_account_id = FND_API.g_miss_num OR
         p_code_conversion_rec.cust_account_id IS NULL
      THEN
         IF p_code_conversion_rec.party_id = FND_API.g_miss_num OR
            p_code_conversion_rec.party_id IS NULL
         THEN
            l_org_dummy := 0;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
               OZF_UTILITY_PVT.debug_message('External code '  ||p_code_conversion_rec.external_code );
               OZF_UTILITY_PVT.debug_message('Start date active '||  p_code_conversion_rec.start_date_active );
               OZF_UTILITY_PVT.debug_message('End date active '  || p_code_conversion_rec.end_date_active );
               OZF_UTILITY_PVT.debug_message('Org ID '  || p_code_conversion_rec.org_id );
            END IF;

            OPEN csr_code_conv_4org(p_code_conversion_rec.external_code,
                                    p_code_conversion_rec.start_date_active,
                                    p_code_conversion_rec.end_date_active
                                            );
            FETCH csr_code_conv_4org
            INTO  l_org_dummy;
            CLOSE csr_code_conv_4org;


            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
               OZF_UTILITY_PVT.debug_message('Duplicate code map value ' || p_code_conversion_rec.external_code || ' for org ' || p_code_conversion_rec.org_id );
               OZF_UTILITY_PVT.debug_message('and internal code '  ||p_code_conversion_rec.internal_code );
               OZF_UTILITY_PVT.debug_message('with start date active '||  p_code_conversion_rec.start_date_active );
               OZF_UTILITY_PVT.debug_message('and end date active '  || p_code_conversion_rec.end_date_active );
               OZF_UTILITY_PVT.debug_message('External Code ' || l_external_code);
            END IF;
            IF l_org_dummy > 0 THEN
               l_valid_flag :=  FND_API.g_false;
            END IF;
         ELSE
           l_party_dummy := NULL;
           OPEN csr_code_conv_4party(p_code_conversion_rec.party_id,
                                     p_code_conversion_rec.external_code,
                                     p_code_conversion_rec.start_date_active,
                                     p_code_conversion_rec.end_date_active);
           FETCH csr_code_conv_4party
           INTO  l_party_dummy;
           CLOSE csr_code_conv_4party;

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
              OZF_UTILITY_PVT.debug_message('Duplicate code map value ' || p_code_conversion_rec.external_code || ' for party ' || p_code_conversion_rec.party_id );
              OZF_UTILITY_PVT.debug_message('and internal code '  ||p_code_conversion_rec.internal_code );
              OZF_UTILITY_PVT.debug_message('with start date active '||  p_code_conversion_rec.start_date_active );
              OZF_UTILITY_PVT.debug_message('and end date active '  || p_code_conversion_rec.end_date_active );
            END IF;

           IF l_party_dummy > 0 THEN
              l_valid_flag :=  FND_API.g_false;
           END IF;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
              OZF_UTILITY_PVT.debug_message('Count of code map for party ' || l_party_dummy);
            END IF;
         END IF;
      ELSE
         l_acct_dummy := NULL;
         OPEN csr_code_conv_4acct(p_code_conversion_rec.cust_account_id,
                                           p_code_conversion_rec.external_code,
                                           p_code_conversion_rec.start_date_active,
                                           p_code_conversion_rec.end_date_active
                                          );
         FETCH  csr_code_conv_4acct INTO  l_acct_dummy;
         CLOSE csr_code_conv_4acct;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
            OZF_UTILITY_PVT.debug_message('Duplicate code map value ' || p_code_conversion_rec.external_code || ' for account ' || p_code_conversion_rec.cust_account_id );
            OZF_UTILITY_PVT.debug_message('and internal code '  ||p_code_conversion_rec.internal_code );
            OZF_UTILITY_PVT.debug_message('with start date active '||  p_code_conversion_rec.start_date_active );
            OZF_UTILITY_PVT.debug_message('and end date active '  ||nvl(p_code_conversion_rec.end_date_active,sysdate) );
            OZF_UTILITY_PVT.debug_message('Count of code map for account ' || l_acct_dummy);
         END IF;
         IF l_acct_dummy > 0 THEN
            l_valid_flag :=  FND_API.g_false;
         END IF;
      END IF;
   ELSE
      l_valid_flag := FND_API.g_true;
   END IF;

   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CODE_CONVERSION_DUPLICATE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

END Check_Uniq_Code_Conversion;


-- Start of Comments
--
-- Required Items Check procedure
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments

PROCEDURE Check_Code_Conv_Req_Items
(
    p_code_conversion_rec       IN    code_conversion_rec_type,
    p_validation_mode           IN    VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY   VARCHAR2
)
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Check_Code_Conv_Req_Items';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
     OZF_UTILITY_PVT.debug_message('in '||l_api_name);
   END IF;

   IF p_code_conversion_rec.external_code =  FND_API.g_miss_char OR
      p_code_conversion_rec.external_code IS NULL
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_EXTERNAL_CODE_MISSING'||NVL(p_code_conversion_rec.external_code,'NULL'));
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message('external code '||p_code_conversion_rec.external_code);
      OZF_UTILITY_PVT.debug_message('end of check_code_conv_req_items');
   END IF;

END check_code_conv_req_items;

-- Start of Comments
--
-- Start date and End Date Check
--
-- End of Comments

PROCEDURE Check_Code_Conversion_Dt
(
    p_code_conversion_rec       IN    code_conversion_rec_type,
    p_validation_mode           IN    VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT   NOCOPY   VARCHAR2
)
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'check_code_conversion_dt';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
     OZF_UTILITY_PVT.debug_message('in '||l_api_name);
  END IF;

   IF p_validation_mode =  JTF_PLSQL_API.g_create THEN

      IF NVL(p_code_conversion_rec.start_date_active,TRUNC(SYSDATE)) < TRUNC(SYSDATE)
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CODE_CONV_STDATE_BKDATED');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   -- Fix for 3928270

   -- IF NVL(p_code_conversion_rec.end_date_active,TRUNC(SYSDATE)) < TRUNC(SYSDATE)
   IF (TO_DATE(TO_CHAR(NVL(p_code_conversion_rec.end_date_active,TRUNC(SYSDATE)), 'DD/MM/YYYY'),'DD/MM/YYYY') < TRUNC(SYSDATE))
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CODE_CONV_ENDDATE_BKDATED');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Fix for 3928270

   --IF NVL(p_code_conversion_rec.Start_Date_Active,TRUNC(SYSDATE))  >
   --   NVL(p_code_conversion_rec.end_date_active,NVL(p_code_conversion_rec.Start_Date_Active,TRUNC(SYSDATE)) + 1)
   IF (TO_DATE(TO_CHAR(NVL(p_code_conversion_rec.Start_Date_Active,TRUNC(SYSDATE)),'DD/MM/YYYY'),'DD/MM/YYYY')  >
      TO_DATE(TO_CHAR(NVL(p_code_conversion_rec.end_date_active, NVL(p_code_conversion_rec.Start_Date_Active,TRUNC(SYSDATE)) +1 ), 'DD/MM/YYYY'),'DD/MM/YYYY'))
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CODE_CONV_STDATE_GREATE');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

END check_code_conversion_dt;

PROCEDURE  check_code_conversion_items
(
   p_code_conversion_rec   IN    code_conversion_rec_type,
   p_validation_mode       IN    VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2
)

IS
  l_api_name                CONSTANT VARCHAR2(30) := 'check_code_conversion_items';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message('in '||l_api_name);
   END IF;

   check_code_conv_req_items( p_code_conversion_rec,
                              p_validation_mode,
                              x_return_status
                             );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
   END IF;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
       OZF_UTILITY_PVT.debug_message('after check_code_conv_req_items ' );
    END IF;


    check_uniq_code_conversion( p_code_conversion_rec,
                                p_validation_mode,
                                x_return_status
                                 );
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
       OZF_UTILITY_PVT.debug_message('after check_uniq_code_conversion ' );
    END IF;

    check_code_conversion_dt (p_code_conversion_rec,
                              p_validation_mode,
                              x_return_status
                                );
    IF x_return_status <> FND_API.g_ret_sts_success Then
       RETURN;
    END IF;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
       OZF_UTILITY_PVT.debug_message('after check_code_conversion_dt ' );
    END IF;

END check_code_conversion_items;
-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments

PROCEDURE Validate_Code_Conversion(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2,
    p_code_conversion_tbl        IN    code_conversion_tbl_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )

IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Validate_code_conversion';
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   l_object_version_number   NUMBER;

   l_code_conversion_rec     code_conversion_rec_type ;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_code_conversion_pvt;

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

      FOR i in 1 .. p_code_conversion_tbl.count
      LOOP
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
            OZF_UTILITY_PVT.debug_message('inside the loop p_code_conversion_tbl ' );
         END IF;
         l_code_conversion_rec := p_code_conversion_tbl(i);

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
            OZF_UTILITY_PVT.debug_message('External code '  || l_code_conversion_rec.external_code );
            OZF_UTILITY_PVT.debug_message('Start date active '|| l_code_conversion_rec.start_date_active );
            OZF_UTILITY_PVT.debug_message('End date active '  || l_code_conversion_rec.end_date_active );
         END IF;

         check_code_conversion_items(
           p_code_conversion_rec      => l_code_conversion_rec,
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
      ROLLBACK TO validate_code_conversion_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO validate_code_conversion_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO validate_code_conversion_pvt;
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

END Validate_code_conversion;


-- Start of Comments
--
--  get_claim_reason
--       Translate the Customer Reason to the Internal (Oracle) Reason.
--
-- End of Comments
PROCEDURE convert_code(
    p_cust_account_id      IN NUMBER,
    p_party_id             IN NUMBER, -- added new
    p_code_conversion_type IN VARCHAR2,
    p_external_code        IN VARCHAR2,
    x_internal_code        OUT NOCOPY VARCHAR2,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2
   )

IS

 l_api_name                  CONSTANT VARCHAR2(30) := 'convert_code';
 l_api_version_number        CONSTANT NUMBER   := 1.0;

 CURSOR csr_get_internal_code_Acct( cv_Cust_Account_Id NUMBER
                                  , cv_external_code VARCHAR2
                                  , cv_conv_type varchar2 )
 IS
 SELECT  internal_code
 FROM    ozf_code_conversions
 WHERE   cust_account_id = cv_cust_account_id
 AND     UPPER(external_code) LIKE UPPER(cv_external_code)
 AND     start_date_active <= SYSDATE
 AND    (end_date_active >= SYSDATE
         OR end_date_active IS NULL)
 AND     code_conversion_type = cv_conv_type;

 CURSOR csr_get_internal_code_Party( cv_party_Id NUMBER,
                                     cv_external_code VARCHAR2,
                                     cv_conv_type VARCHAR2 ) IS
 SELECT  internal_code
 FROM    ozf_code_conversions
 WHERE   party_id = cv_party_id
 AND     UPPER(external_code) LIKE UPPER(cv_external_code)
 AND     start_date_active <= SYSDATE
 AND    (end_date_active >= SYSDATE
         OR end_date_active IS NULL)
 AND     cust_account_id IS NULL
 AND     code_conversion_type = cv_conv_type;

 CURSOR csr_get_internal_code(  cv_external_code VARCHAR2,
                                cv_conv_type VARCHAR2) IS
 SELECT  internal_code
 FROM    ozf_code_conversions
 WHERE   UPPER(external_code) LIKE UPPER(cv_external_code)
 AND     start_date_active <= SYSDATE
 AND    (end_date_active >= SYSDATE
         or end_date_active IS NULL)
 AND     party_id IS NULL
 AND     cust_account_id IS NULL
 AND     code_conversion_type = cv_conv_type;

 l_external_code      VARCHAR2(150) := NULL;
 l_internal_code      VARCHAR2(150) := NULL;

 l_party_id           NUMBER := Null;
 l_org_id             NUMBER := null;


BEGIN

   X_Return_Status := FND_API.g_ret_sts_success;

--- in case of multiple rows what will be the result?   error out or get the first record.

   OPEN  csr_get_internal_code_Acct(p_cust_account_id
                                  , p_external_code
                                  , p_code_conversion_type);
   FETCH csr_get_internal_code_Acct
   INTO  l_internal_code;
   CLOSE csr_get_internal_code_Acct;

   x_internal_code := NULL;

   IF l_internal_code IS NULL THEN
     OPEN  csr_get_internal_code_party(p_party_id,
                                       p_external_code,
                                       p_code_conversion_type);
     FETCH csr_get_internal_code_party Into  l_internal_code;

     IF csr_get_internal_code_party%NOTFOUND THEN
        OPEN  csr_get_internal_code( p_external_code
                                    ,p_code_conversion_type);
        FETCH csr_get_internal_code INTO  l_internal_code;

        IF csr_get_internal_code%NOTFOUND THEN
           l_internal_code := NULL;
        END IF;
        CLOSE csr_get_internal_code;

     END IF;


     CLOSE csr_get_internal_code_party;
   END IF;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message(' Internal Code ' || l_internal_code);
   END IF;
   x_internal_code := l_internal_code;

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.g_ret_sts_unexp_error;

    IF csr_get_internal_code_acct%ISOPEN THEN
      CLOSE csr_get_internal_code_acct;
    END IF;

    IF csr_get_internal_code_party%ISOPEN THEN
      CLOSE csr_get_internal_code_party;
    END IF;

    IF csr_get_internal_code%ISOPEN THEN
      CLOSE csr_get_internal_code;
    END IF;
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


END Convert_Code;

PROCEDURE Check_uniq_supp_code_conv(
    p_supp_code_conversion_rec       IN    supp_code_conversion_rec_type,
    p_validation_mode           IN    VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY   VARCHAR2
)
IS
  l_api_name                CONSTANT VARCHAR2(50) := 'Check_uniq_supp_code_conversion';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

   CURSOR csr_code_conv(cv_supp_trade_profile_id NUMBER
                             , cv_external_code VARCHAR2
                             , cv_internal_code VARCHAR2
                             , cv_start_date_active DATE
                             , cv_end_date_active DATE
                             , cv_conv_id NUMBER := -1)
   IS
        select code_conversion_id from ozf_supp_code_conversions_all where external_code = cv_external_code
 and code_conversion_id <> cv_conv_id
 and supp_trade_profile_id = cv_supp_trade_profile_id
 and ( to_date(cv_start_date_active,'dd-mm-yyyy')  between
 to_date(start_date_active,'dd-mm-yyyy') and nvl(end_date_active,to_Date('31-12-9999','dd-mm-yyyy'))
 or nvl(to_date(cv_end_date_active,'dd-mm-yyyy'),to_Date('31-12-9999','dd-mm-yyyy')) between
 to_date(start_date_Active,'dd-mm-yyyy') and nvl(to_date(end_date_active,'dd-mm-yyyy'),to_Date('31-12-9999','dd-mm-yyyy')))
        union
 select code_conversion_id from ozf_supp_code_conversions_all where internal_code = cv_internal_code
 and code_conversion_id <> cv_conv_id
 and supp_trade_profile_id = cv_supp_trade_profile_id
 and  ( to_date(cv_start_date_active,'dd-mm-yyyy')  between to_date(start_date_active,'dd-mm-yyyy')
 and nvl(end_date_active,to_Date('31-12-9999','dd-mm-yyyy'))
 or nvl(to_date(cv_end_date_active,'dd-mm-yyyy'),to_Date('31-12-9999','dd-mm-yyyy')) between
 to_date(start_date_Active,'dd-mm-yyyy') and nvl(to_date(end_date_active,'dd-mm-yyyy'),to_Date('31-12-9999','dd-mm-yyyy')));

        l_valid_flag         VARCHAR2(30);
        l_dummy              NUMBER := 0;
        l_external_code      VARCHAR2(30);


BEGIN
/* 3/25/2008 -gdeepika- Bug 6832508 */
/* For the code conversions at a supplier site , only one valid internal code
should exist for a particular external code on a particular date.*/
   x_return_status := FND_API.g_ret_sts_success;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message('in '||l_api_name);
      OZF_UTILITY_PVT.debug_message('Dummy value ' || l_dummy);
   END IF;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

   OPEN csr_code_conv(p_supp_code_conversion_rec.supp_trade_profile_id,
                             p_supp_code_conversion_rec.external_code,
                             p_supp_code_conversion_rec.internal_code,
                             p_supp_code_conversion_rec.start_date_active,
                             p_supp_code_conversion_rec.end_date_active);


    ELSIF p_validation_mode = JTF_PLSQL_API.g_update THEN
      OPEN csr_code_conv(p_supp_code_conversion_rec.supp_trade_profile_id,
                             p_supp_code_conversion_rec.external_code,
                             p_supp_code_conversion_rec.internal_code,
                             p_supp_code_conversion_rec.start_date_active,
                             p_supp_code_conversion_rec.end_date_active,
                             p_supp_code_conversion_rec.code_conversion_id);

    END IF;
    FETCH csr_code_conv
    INTO  l_dummy;
    CLOSE csr_code_conv;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
       OZF_UTILITY_PVT.debug_message('Duplicate code map value ' || p_supp_code_conversion_rec.external_code || ' for org ' || p_supp_code_conversion_rec.org_id );
       OZF_UTILITY_PVT.debug_message('and internal code '  ||p_supp_code_conversion_rec.internal_code );
       OZF_UTILITY_PVT.debug_message('with start date active '||  p_supp_code_conversion_rec.start_date_active );
       OZF_UTILITY_PVT.debug_message('and end date active '  || p_supp_code_conversion_rec.end_date_active );
       OZF_UTILITY_PVT.debug_message('External Code ' || l_external_code);
   END IF;
    IF l_dummy > 0 THEN
       l_valid_flag :=  FND_API.g_false;

    ELSE
      l_valid_flag := FND_API.g_true;

    END IF;

   IF l_valid_flag = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CODE_CONVERSION_DUPLICATE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;


END Check_Uniq_supp_Code_Conv;

-- Start of Comments
--
-- Required Items Check procedure
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments

PROCEDURE Check_supp_code_Conv_Req_Items
(
    p_supp_code_conversion_rec       IN    supp_code_conversion_rec_type,
    p_validation_mode           IN    VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY   VARCHAR2
)
IS
  l_api_name                CONSTANT VARCHAR2(50) := 'Check_supp_code_Conv_Req_Items';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
     OZF_UTILITY_PVT.debug_message('in '||l_api_name);
   END IF;

   IF p_supp_code_conversion_rec.external_code =  FND_API.g_miss_char OR
      p_supp_code_conversion_rec.external_code IS NULL
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_EXTERNAL_CODE_MISSING'||NVL(p_supp_code_conversion_rec.external_code,'NULL'));
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message('external code '||p_supp_code_conversion_rec.external_code);
      OZF_UTILITY_PVT.debug_message('end of check_supp_code_conv_req_items');
   END IF;

END check_supp_code_conv_req_items;

-- Start of Comments
--
-- Start date and End Date Check
--
-- End of Comments

PROCEDURE Check_supp_code_Conversion_Dt
(
    p_supp_code_conversion_rec       IN    supp_code_conversion_rec_type,
    p_validation_mode           IN    VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT   NOCOPY   VARCHAR2
)
IS
  l_api_name                CONSTANT VARCHAR2(50) := 'check_supp_code_conversion_dt';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
     OZF_UTILITY_PVT.debug_message('in '||l_api_name);
  END IF;

   IF p_validation_mode =  JTF_PLSQL_API.g_create THEN

      IF NVL(p_supp_code_conversion_rec.start_date_active,TRUNC(SYSDATE)) < TRUNC(SYSDATE)
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CODE_CONV_STDATE_BKDATED');
            FND_MSG_PUB.add;
         END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
      END IF;
   END IF;

   -- Fix for 3928270

   -- IF NVL(p_supp_code_conversion_rec.end_date_active,TRUNC(SYSDATE)) < TRUNC(SYSDATE)
   IF (TO_DATE(TO_CHAR(NVL(p_supp_code_conversion_rec.end_date_active,TRUNC(SYSDATE)), 'DD/MM/YYYY'),'DD/MM/YYYY') < TRUNC(SYSDATE))
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CODE_CONV_ENDDATE_BKDATED');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;


   IF (TO_DATE(TO_CHAR(NVL(p_supp_code_conversion_rec.Start_Date_Active,TRUNC(SYSDATE)),'DD/MM/YYYY'),'DD/MM/YYYY')  >
      TO_DATE(TO_CHAR(NVL(p_supp_code_conversion_rec.end_date_active, NVL(p_supp_code_conversion_rec.Start_Date_Active,TRUNC(SYSDATE)) +1 ), 'DD/MM/YYYY'),'DD/MM/YYYY'))
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CODE_CONV_STDATE_GREATE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

END check_supp_code_conversion_dt;


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments



-- Start of Comments
--
--  get_claim_reason
--       Translate the Customer Reason to the Internal (Oracle) Reason.
--
-- End of Comments
PROCEDURE convert_supp_code(
    p_supp_trade_profile_id      IN NUMBER,
    p_code_conversion_type IN VARCHAR2,
    p_external_code        IN VARCHAR2,
    x_internal_code        OUT NOCOPY VARCHAR2,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2
   )

IS

 l_api_name                  CONSTANT VARCHAR2(30) := 'convert_code';
 l_api_version_number        CONSTANT NUMBER   := 1.0;


 CURSOR csr_get_internal_code(  cv_supp_trade_profile_id NUMBER,
                                cv_external_code VARCHAR2,
                                cv_conv_type VARCHAR2) IS
 SELECT  internal_code
 FROM    ozf_supp_code_conversions
 WHERE   UPPER(external_code) LIKE UPPER(cv_external_code)
 AND     start_date_active <= SYSDATE
 AND    (end_date_active >= SYSDATE
         or end_date_active IS NULL)
 AND     code_conversion_type = cv_conv_type
 AND supp_trade_profile_id = cv_supp_trade_profile_id;

 l_external_code      VARCHAR2(150) := NULL;
 l_internal_code      VARCHAR2(150) := NULL;


BEGIN

        X_Return_Status := FND_API.g_ret_sts_success;


        OPEN  csr_get_internal_code( p_supp_trade_profile_id
                                     ,p_external_code
                                    ,p_code_conversion_type);
        FETCH csr_get_internal_code INTO  l_internal_code;

        IF csr_get_internal_code%NOTFOUND THEN
           l_internal_code := NULL;
        END IF;
        CLOSE csr_get_internal_code;


        x_internal_code := l_internal_code;

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.g_ret_sts_unexp_error;

    IF csr_get_internal_code%ISOPEN THEN
      CLOSE csr_get_internal_code;
    END IF;
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


END Convert_Supp_Code;

PROCEDURE  check_supp_code_conv_items
(
   p_supp_code_conversion_rec   IN    supp_code_conversion_rec_type,
   p_validation_mode       IN    VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2
)

IS
  l_api_name                CONSTANT VARCHAR2(50) := 'check_supp_code_conversion_items';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
      OZF_UTILITY_PVT.debug_message('in '||l_api_name);
   END IF;

   check_supp_code_conv_req_items( p_supp_code_conversion_rec,
                              p_validation_mode,
                              x_return_status
                             );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
   END IF;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
       OZF_UTILITY_PVT.debug_message('after check_supp_code_conv_req_items ' );
    END IF;


    check_uniq_supp_code_conv( p_supp_code_conversion_rec,
                                p_validation_mode,
                                x_return_status
                                 );
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
       OZF_UTILITY_PVT.debug_message('after check_uniq_supp_code_conversion ' );
    END IF;

    check_supp_code_conversion_dt (p_supp_code_conversion_rec,
                              p_validation_mode,
                              x_return_status
                                );
    IF x_return_status <> FND_API.g_ret_sts_success Then
       RETURN;
    END IF;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
       OZF_UTILITY_PVT.debug_message('after check_supp_code_conversion_dt ' );
    END IF;

END check_supp_code_conv_items;
PROCEDURE Validate_supp_code_Conv(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2,
    p_supp_code_conversion_tbl        IN    supp_code_conversion_tbl_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )

IS
   l_api_name                CONSTANT VARCHAR2(50) := 'Validate_supp_code_conversion';
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   l_object_version_number   NUMBER;

   l_supp_code_conversion_rec     supp_code_conversion_rec_type ;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_supp_code_conv_pvt;

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

      FOR i in 1 .. p_supp_code_conversion_tbl.count
      LOOP
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
            OZF_UTILITY_PVT.debug_message('inside the loop p_supp_code_conversion_tbl ' );
         END IF;
         l_supp_code_conversion_rec := p_supp_code_conversion_tbl(i);

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
            OZF_UTILITY_PVT.debug_message('External code '  || l_supp_code_conversion_rec.external_code );
            OZF_UTILITY_PVT.debug_message('Start date active '|| l_supp_code_conversion_rec.start_date_active );
            OZF_UTILITY_PVT.debug_message('End date active '  || l_supp_code_conversion_rec.end_date_active );
         END IF;

         check_supp_code_conv_items(
           p_supp_code_conversion_rec => l_supp_code_conversion_rec,
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
      ROLLBACK TO validate_supp_code_conv_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO validate_supp_code_conv_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   WHEN OTHERS THEN
     ROLLBACK TO validate_supp_code_conv_pvt;
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

END Validate_supp_code_conv;

PROCEDURE create_supp_code_conversion
(
   p_api_version_number         IN          NUMBER,
   p_init_msg_list              IN          VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN          VARCHAR2     := FND_API.G_FALSE,
   p_validation_level           IN          NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   p_supp_code_conversion_tbl        IN          supp_code_conversion_tbl_type,
   x_supp_code_conversion_id_tbl     OUT NOCOPY  JTF_NUMBER_TABLE
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'create_supp_code_conversion';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER;
   l_code_conversion_id        NUMBER;
   l_supp_code_conversion_rec       supp_code_conversion_rec_type;



BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_supp_code_conv_pvt;

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
           OZF_UTILITY_PVT.debug_message( 'No of records to be created'||p_supp_code_conversion_tbl.count);
        END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name);
          -- Invoke validation procedures
          Validate_supp_code_Conv(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_validation_mode        => JTF_PLSQL_API.G_CREATE,
                 p_supp_code_conversion_tbl    => p_supp_code_conversion_tbl,
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

      l_code_conversion_id     := NULL;
      l_object_version_number  := NULL;

      x_supp_code_conversion_id_tbl := JTF_NUMBER_TABLE();

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
          OZF_UTILITY_PVT.debug_message( 'No of rows to be created '|| p_supp_code_conversion_tbl.count);
        END IF;

      FOR i IN 1 .. p_supp_code_conversion_tbl.count
      LOOP

        l_supp_code_conversion_rec := p_supp_code_conversion_tbl(i);

        IF (l_supp_code_conversion_rec.org_id IS NULL)      THEN
             l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements
        ELSE
             l_org_id := l_supp_code_conversion_rec.org_id;
        END IF;
        SELECT ozf_supp_code_conv_all_s.nextval INTO l_code_conversion_id FROM DUAL;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
            OZF_UTILITY_PVT.debug_message( 'l_org_id ' || l_org_id);
            OZF_UTILITY_PVT.debug_message( 'Code Conversion ID '|| l_code_conversion_id);
        END IF;

        BEGIN


         OZF_CODE_CONVERSION_PKG.Insert_Supp_code_conv_Row(
          px_code_conversion_id     =>    l_code_conversion_id,
          px_object_version_number  =>    l_object_version_number,
          p_last_update_date        =>    SYSDATE,
          p_last_updated_by         =>    FND_GLOBAL.USER_ID,
          p_creation_date           =>    SYSDATE,
          p_created_by              =>    FND_GLOBAL.USER_ID,
          p_last_update_login       =>    FND_GLOBAL.CONC_LOGIN_ID,
          px_org_id                 =>    l_org_id,
          p_supp_trade_profile_id   =>    l_supp_code_conversion_rec.supp_trade_profile_id,
          p_code_conversion_type    =>    l_supp_code_conversion_rec.code_conversion_type,
          p_external_code           =>    l_supp_code_conversion_rec.external_code,
          p_internal_code           =>    l_supp_code_conversion_rec.internal_code,
          p_description             =>    l_supp_code_conversion_rec.description,
          p_start_date_active       =>    nvl(l_supp_code_conversion_rec.start_date_active,sysdate),
          p_end_date_active         =>    l_supp_code_conversion_rec.end_date_active,
          p_attribute_category      =>    l_supp_code_conversion_rec.attribute_category,
          p_attribute1              =>    l_supp_code_conversion_rec.attribute1,
          p_attribute2              =>    l_supp_code_conversion_rec.attribute2,
          p_attribute3              =>    l_supp_code_conversion_rec.attribute3,
          p_attribute4              =>    l_supp_code_conversion_rec.attribute4,
          p_attribute5              =>    l_supp_code_conversion_rec.attribute5,
          p_attribute6              =>    l_supp_code_conversion_rec.attribute6,
          p_attribute7              =>    l_supp_code_conversion_rec.attribute7,
          p_attribute8              =>    l_supp_code_conversion_rec.attribute8,
          p_attribute9              =>    l_supp_code_conversion_rec.attribute9,
          p_attribute10             =>    l_supp_code_conversion_rec.attribute10,
          p_attribute11             =>    l_supp_code_conversion_rec.attribute11,
          p_attribute12             =>    l_supp_code_conversion_rec.attribute12,
          p_attribute13             =>    l_supp_code_conversion_rec.attribute13,
          p_attribute14             =>    l_supp_code_conversion_rec.attribute14,
          p_attribute15             =>    l_supp_code_conversion_rec.attribute15);

        EXCEPTION
          WHEN OTHERS THEN
              OZF_UTILITY_PVT.debug_message (SQLERRM ||'  Error in creating supp_code conversion map');
              RAISE FND_API.G_EXC_ERROR;
        END;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' after insert call - supp_code conversion id' || l_code_conversion_id);
           OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' after insert call - obj version no ' || l_supp_code_conversion_rec.Object_Version_Number);
        END IF;

      x_supp_code_conversion_id_tbl.extend;
      x_supp_code_conversion_id_tbl(x_supp_code_conversion_id_tbl.count) :=  l_code_conversion_id;

   end loop;

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
     ROLLBACK TO create_supp_code_conv_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_code_conversion_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
  WHEN OTHERS THEN
     ROLLBACK TO create_supp_code_conv_pvt;
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

END create_supp_code_conversion ;


PROCEDURE Update_supp_code_conversion
(
    p_api_version_number         IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_supp_code_conversion_tbl        IN          supp_code_conversion_tbl_type  ,
    x_object_version_number      OUT NOCOPY  JTF_NUMBER_TABLE
    )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Update_supp_code_conversion';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_object_version_number   NUMBER;

  l_code_conversion_id  NUMBER;

  CURSOR csr_supp_code_conversion(cv_code_conversion_id NUMBER)
  IS
  SELECT  code_conversion_id,
         object_version_number,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         org_id,
         supp_trade_profile_id,
         code_conversion_type,
         external_code,
         internal_code,
         description,
         start_date_active,
         end_date_active,
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
 FROM    ozf_supp_code_conversions_all
 WHERE   code_conversion_id = cv_code_conversion_id;

 CURSOR get_org
 IS
 SELECT org_id FROM ozf_sys_parameters;

l_supp_code_conversion_rec   supp_code_conversion_rec_type;
l_supp_code_conversion_tbl   supp_code_conversion_tbl_type;
l_org_id                NUMBER;
p_supp_code_conversion_rec   supp_code_conversion_rec_type;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_supp_code_conv_pvt;

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

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('p_supp_code_conversion_tbl(1).description: ' || p_supp_code_conversion_tbl(1).description );
      END IF;

      FOR i in 1 .. p_supp_code_conversion_tbl.count
      LOOP
        p_supp_code_conversion_rec := p_supp_code_conversion_tbl(i);
        l_code_conversion_id  := p_supp_code_conversion_rec.code_conversion_id;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'supp_code Conversion ID' || l_code_conversion_id);
        END IF;

      --  Check for the existance of the record
        OPEN csr_supp_code_conversion(l_code_conversion_id);
        FETCH csr_supp_code_conversion
        INTO   l_supp_code_conversion_rec.code_conversion_id
              ,l_supp_code_conversion_rec.object_version_number
              ,l_supp_code_conversion_rec.last_update_date
              ,l_supp_code_conversion_rec.last_updated_by
              ,l_supp_code_conversion_rec.creation_date
              ,l_supp_code_conversion_rec.created_by
              ,l_supp_code_conversion_rec.last_update_login
              ,l_supp_code_conversion_rec.org_id
              ,l_supp_code_conversion_rec.supp_trade_profile_id
              ,l_supp_code_conversion_rec.code_conversion_type
              ,l_supp_code_conversion_rec.external_code
              ,l_supp_code_conversion_rec.internal_code
              ,l_supp_code_conversion_rec.description
              ,l_supp_code_conversion_rec.start_date_active
              ,l_supp_code_conversion_rec.end_date_active
              ,l_supp_code_conversion_rec.attribute_category
              ,l_supp_code_conversion_rec.attribute1
              ,l_supp_code_conversion_rec.attribute2
              ,l_supp_code_conversion_rec.attribute3
              ,l_supp_code_conversion_rec.attribute4
              ,l_supp_code_conversion_rec.attribute5
              ,l_supp_code_conversion_rec.attribute6
              ,l_supp_code_conversion_rec.attribute7
              ,l_supp_code_conversion_rec.attribute8
              ,l_supp_code_conversion_rec.attribute9
              ,l_supp_code_conversion_rec.attribute10
              ,l_supp_code_conversion_rec.attribute11
              ,l_supp_code_conversion_rec.attribute12
              ,l_supp_code_conversion_rec.attribute13
              ,l_supp_code_conversion_rec.attribute14
              ,l_supp_code_conversion_rec.attribute15
              ,l_supp_code_conversion_rec.security_group_id;

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
              OZF_UTILITY_PVT.debug_message('Existing description '|| l_supp_code_conversion_rec.description);
           END IF;

         IF ( csr_supp_code_conversion%NOTFOUND) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
              OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'nodata for upd');
            END IF;

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
              FND_MSG_PUB.add;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
        CLOSE csr_supp_code_conversion;


        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
          OZF_UTILITY_PVT.debug_message( 'Pre Object Version Number ' || l_supp_code_conversion_rec.object_version_number);
          OZF_UTILITY_PVT.debug_message( 'Post Object Version Number' || P_supp_code_conversion_rec.object_version_number);
        END IF;

      --- Check the Version Number for Locking
        IF l_supp_code_conversion_rec.object_version_number <> P_supp_code_conversion_rec.Object_Version_number
        THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
               OZF_UTILITY_PVT.debug_message( 'dbver' || l_supp_code_conversion_rec.object_version_number);
               OZF_UTILITY_PVT.debug_message( 'reqver' || P_supp_code_conversion_rec.object_version_number);
            END IF;

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
             FND_MESSAGE.Set_Name('OZF', 'OZF_API_RESOURCE_LOCKED');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;


     -- Update internal code only when it is NUll
        IF l_supp_code_conversion_rec.internal_code IS NOT NULL  AND
           l_supp_code_conversion_rec.internal_code <> P_supp_code_conversion_rec.internal_code
        THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_CODE_CONV_UPD_INTLCODE');
              FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'Existing End Date' || l_supp_code_conversion_rec.End_Date_Active);
           OZF_UTILITY_PVT.debug_message( 'Updated End Date' || p_supp_code_conversion_rec.End_Date_Active);
        END IF;

     -- Update End date only when it is NUll or a future date
        IF  trunc(nvl(l_supp_code_conversion_Rec.End_Date_Active,sysdate+1)) <= TRUNC(SYSDATE)
        AND
            Trunc(l_supp_code_conversion_Rec.End_Date_Active) <> Trunc(P_supp_code_conversion_Rec.End_Date_Active)
        THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_CODE_CONV_UPD_ENDDATE');
              FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'Existing Start Date' || l_supp_code_conversion_rec.Start_Date_Active);
           OZF_UTILITY_PVT.debug_message( 'Updated Start Date' || p_supp_code_conversion_rec.Start_Date_Active);
        END IF;

     ---Update not allowed for  Start Date when start date is earlier than current date
        IF  trunc(l_supp_code_conversion_Rec.Start_Date_Active)
        <> trunc(P_supp_code_conversion_Rec.Start_Date_Active)
        THEN
            IF p_supp_code_conversion_Rec.Start_Date_Active < TRUNC(SYSDATE)
            THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                FND_MESSAGE.Set_Name('OZF', 'OZF_CODE_CONV_UPD_STARTDATE');
                FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

           IF  l_supp_code_conversion_Rec.end_date_active <  p_supp_code_conversion_Rec.Start_Date_Active THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                OZF_UTILITY_PVT.debug_message ('Cannot update an end dated code conversion map');
              END IF;
              raise FND_API.G_EXC_ERROR;
            END IF;

       END IF;

     -- Update not allowed for External Code
        IF l_supp_code_conversion_Rec.external_Code <> P_supp_code_conversion_Rec.external_Code
        THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_CODE_CONV_UPD_EXTCD');
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
            Validate_supp_code_Conv(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_level       => p_validation_level,
            p_validation_mode        => JTF_PLSQL_API.G_UPDATE,
            p_supp_code_conversion_tbl    => p_supp_code_conversion_tbl,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);
        END IF;

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_supp_code_conversion_rec.org_id IS NULL) THEN
            l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements
        ELSE
           l_org_id := l_supp_code_conversion_rec.org_id;
        END IF;


     -- Call Update Table Handler
     -- Debug Message
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
           OZF_UTILITY_PVT.debug_message( 'Private API: Calling Update table handler');
        END IF;
        BEGIN
           OZF_CODE_CONVERSION_PKG.Update_Supp_Code_Conv_Row(
           p_code_conversion_id     =>    l_code_conversion_id,
           p_object_version_number  =>     p_supp_code_conversion_rec.object_version_number,
           p_last_update_date       =>     SYSDATE,
           p_last_updated_by        =>     FND_GLOBAL.USER_ID,
           p_last_update_login      =>     FND_GLOBAL.CONC_LOGIN_ID,
           p_org_id                 =>     l_org_id,
           p_supp_trade_profile_id  =>     p_supp_code_conversion_rec.supp_trade_profile_id,
           p_code_conversion_type   =>     p_supp_code_conversion_rec.code_conversion_type,
           p_external_code          =>     p_supp_code_conversion_rec.external_code,
           p_internal_code          =>     p_supp_code_conversion_rec.internal_code,
           p_description            =>     p_supp_code_conversion_rec.description,
           p_start_date_active      =>     p_supp_code_conversion_rec.start_date_active,
           p_end_date_active        =>     p_supp_code_conversion_rec.end_date_active,
           p_attribute_category     =>     p_supp_code_conversion_rec.attribute_category,
           p_attribute1             =>     p_supp_code_conversion_rec.attribute1,
           p_attribute2             =>     p_supp_code_conversion_rec.attribute2,
           p_attribute3             =>     p_supp_code_conversion_rec.attribute3,
           p_attribute4             =>     p_supp_code_conversion_rec.attribute4,
           p_attribute5             =>     p_supp_code_conversion_rec.attribute5,
           p_attribute6             =>     p_supp_code_conversion_rec.attribute6,
           p_attribute7             =>     p_supp_code_conversion_rec.attribute7,
           p_attribute8             =>     p_supp_code_conversion_rec.attribute8,
           p_attribute9             =>     p_supp_code_conversion_rec.attribute9,
           p_attribute10            =>     p_supp_code_conversion_rec.attribute10,
           p_attribute11            =>     p_supp_code_conversion_rec.attribute11,
           p_attribute12            =>     p_supp_code_conversion_rec.attribute12,
           p_attribute13            =>     p_supp_code_conversion_rec.attribute13,
           p_attribute14            =>     p_supp_code_conversion_rec.attribute14,
           p_attribute15            =>     p_supp_code_conversion_rec.attribute15);



        EXCEPTION
           WHEN OTHERS THEN
             OZF_UTILITY_PVT.debug_message (SQLERRM ||'  Error in updating code conversion map');
             RAISE FND_API.G_EXC_ERROR;
        END;

        x_object_version_number.EXTEND;
        x_object_Version_number(x_object_version_number.count) := p_supp_code_conversion_rec.Object_Version_Number;

     END LOOP;


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
    ROLLBACK TO update_supp_code_conv_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_supp_code_conv_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO update_supp_code_conv_pvt;
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

END Update_supp_code_Conversion;



PROCEDURE Update_supp_code_Conv_Tbl(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    P_supp_code_conversion_Tbl        IN  supp_code_conversion_tbl_type
    )
IS
l_api_name                CONSTANT VARCHAR2(35) := 'update_supp_code_conversion_tbl';
l_api_version_number      CONSTANT NUMBER   := 1.0;

p_supp_code_conversion_rec     supp_code_conversion_rec_type;

l_code_conversion_id      NUMBER;
v_code_conversion_id      JTF_NUMBER_TABLE;
v_object_version_number   JTF_NUMBER_TABLE;

l_create_flag             VARCHAR2(10);

l_create_supp_code_conv_tbl    supp_code_conversion_tbl_type := supp_code_conversion_tbl_type();
l_update_supp_code_conv_tbl    supp_code_conversion_tbl_type := supp_code_conversion_tbl_type();

l_cc_cnt                  NUMBER := 0;
l_up_cnt                  NUMBER := 0;

BEGIN
      -- Standard Start of API savepoint
     SAVEPOINT update_supp_code_conv_tbl_pvt;

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
         OZF_UTILITY_PVT.debug_message('Total Number of records '||P_supp_code_conversion_Tbl.count);
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      v_code_conversion_id    :=   JTF_NUMBER_TABLE();
      v_object_version_number :=   JTF_NUMBER_TABLE();

      FOR i IN P_supp_code_conversion_Tbl.first .. P_supp_code_conversion_Tbl.last
      LOOP

          l_code_conversion_id := P_supp_code_conversion_Tbl(i).code_conversion_id;
          P_supp_code_conversion_Rec := P_supp_code_conversion_Tbl(i);

          -- Fix for 3928270

          -- IF p_supp_code_conversion_rec.end_date_active = FND_API.g_miss_date
          -- THEN
             -- p_supp_code_conversion_rec.end_date_active := NULL;
          -- END IF;


         IF l_code_conversion_id IS NULL OR l_code_conversion_id  = -1   then
             l_cc_cnt := l_cc_cnt + 1;

             l_create_supp_code_conv_tbl.extend;
             l_create_supp_code_conv_tbl(l_cc_cnt) := P_supp_code_conversion_Rec;

          ELSE
             l_up_cnt := l_up_cnt + 1;

             l_update_supp_code_conv_tbl.extend;
             l_update_supp_code_conv_tbl(l_up_cnt) := P_supp_code_conversion_Rec;
          END IF;

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
             OZF_UTILITY_PVT.debug_message('End Date '||P_supp_code_conversion_Rec.end_date_active);
          END IF;

      END LOOP;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('No of rows to be created: ' || l_cc_cnt);
         OZF_UTILITY_PVT.debug_message('No of rows to be updated: ' || l_up_cnt);
      END IF;

      IF  l_cc_cnt > 0 THEN
             --- Call to Create Procedure
             Create_supp_code_Conversion
             (
                p_api_version_number         =>  p_api_version_number,
                p_init_msg_list              =>  p_init_msg_list,
                p_commit                     =>  p_commit,
                p_validation_level           =>  p_validation_level,
                x_return_status              =>  x_return_Status,
                x_msg_count                  =>  x_msg_Count,
                x_msg_data                   =>  x_msg_Data,
                p_supp_code_conversion_tbl        =>  l_create_supp_code_conv_tbl,
                x_supp_code_conversion_id_tbl      =>  v_code_conversion_id
              );

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
      END IF;

      IF l_up_cnt > 0 THEN
              -- Call to Update Procedure
            Update_supp_code_conversion (
               p_api_version_number         =>  p_api_version_number ,
               p_init_msg_list              =>  p_init_msg_list,
               p_commit                     =>  p_commit,
               p_validation_level           =>  p_validation_level,
               x_return_status              =>  x_return_Status,
               x_msg_count                  =>  x_msg_Count,
               x_msg_data                   =>  x_msg_Data,
               p_supp_code_conversion_tbl        =>  l_update_supp_code_conv_tbl,
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
    ROLLBACK TO update_supp_code_conv_tbl_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_supp_code_conv_tbl_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO update_supp_code_conv_tbl_pvt;
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


END Update_supp_code_Conv_Tbl;


PROCEDURE Delete_Supp_Code_Conv_Tbl
(
    p_api_version_number         IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_supp_code_conversion_tbl        IN  supp_code_conversion_Tbl_Type
    )
IS
  l_api_name                CONSTANT VARCHAR2(50) := 'delete_supp_code_conversion_tbl';
  l_api_version_number      CONSTANT NUMBER   := 1.0;

  p_supp_code_conversion_rec     supp_code_conversion_rec_type;

  l_code_conversion_id      NUMBER;
  l_object_version_number   NUMBER;


BEGIN
      -- Standard Start of API savepoint
     SAVEPOINT delete_supp_code_conv_tbl_pvt;

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
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      FOR i IN P_supp_code_conversion_Tbl.first .. P_supp_code_conversion_Tbl.last
      LOOP

          l_code_conversion_id := P_supp_code_conversion_Tbl(i).code_conversion_id;
          l_object_version_number := P_supp_code_conversion_Tbl(i).object_version_number;

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
             OZF_UTILITY_PVT.debug_message('supp_code Conversion ID ' || l_code_conversion_id);
             OZF_UTILITY_PVT.debug_message('Object Version Number ' || l_object_version_number);
          END IF;

          IF  l_object_version_number IS NULL
          OR l_code_conversion_id IS NULL THEN

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
                OZF_UTILITY_PVT.debug_message('In If block');
             END IF;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_REQ_PARAMETERS_MISSING');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSE
           Delete_supp_code_Conversion(
             p_api_version_number        => 1.0,
             p_init_msg_list             => FND_API.G_FALSE,
             p_commit                    => FND_API.G_FALSE,
             p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
             x_return_status             => X_Return_Status ,
             x_msg_count                 => X_Msg_Count ,
             x_msg_data                  => X_Msg_Data ,
             p_code_conversion_id        => l_code_conversion_id,
             p_object_version_number     => l_object_version_number
             );


            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

       END IF;

     END LOOP;


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
    ROLLBACK TO delete_supp_code_conv_tbl_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_supp_code_conv_tbl_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO delete_supp_code_conv_tbl_pvt;
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


END Delete_supp_code_Conv_Tbl;




PROCEDURE Delete_supp_code_Conversion
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2   := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_code_conversion_id         IN   NUMBER,
    p_object_version_number      IN   NUMBER
    )
IS
  l_api_name                CONSTANT VARCHAR2(50) := 'Delete_supp_code_conversion';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
  l_object_version_number   NUMBER;

  l_dummy                   NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_supp_code_conv_pvt;

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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;




      -- Api body
      --
      -- Debug Message
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      BEGIN
         OZF_CODE_CONVERSION_PKG.Delete_Supp_Code_Conv_Row( p_code_conversion_id     => p_code_conversion_id,
                                             p_object_version_number  => p_object_version_number );
      EXCEPTION
         WHEN OTHERS THEN
              RAISE FND_API.G_EXC_ERROR;
      END;

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
    ROLLBACK TO delete_supp_code_conv_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_supp_code_conv_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO delete_supp_code_conv_pvt;
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

END Delete_Supp_Code_Conversion;



END Ozf_Code_Conversion_Pvt;


/
