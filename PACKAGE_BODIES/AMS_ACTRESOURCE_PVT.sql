--------------------------------------------------------
--  DDL for Package Body AMS_ACTRESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTRESOURCE_PVT" as
 /*$Header: amsvrscb.pls 120.0 2005/05/31 14:50:17 appldev noship $*/

/*****************************************************************************************/
-- NAME
--   AMS_ActResource_PVT
--
-- HISTORY
-- 1/1/2000    rvaka    CREATED
-- 02/20/2002  gmadana  Rewritten the Package as we are doing Role-Resource relations
--                      are we are using HZ_PARTIES instead of ams_jtf_rs_emp_v.
-- 05/28/2002  gmadana  Added code in Validate_Act_Rsc_Record
-- 08/05/2002  gmadana  Added valiadtions with event start date time
--                      event end date time.
-- 08/18/2002  gmadana  Bug # 2518686. Added time validations with session
-- 08/19/2002  gmadana  Resources cannot be created/updated/deleted
--                      for the event schedules which are cancelled/completed/
--                      archived/on_hold.
-- 08/23/2002  gmadana  Bug # 2518686
-- 04/28/2003  dbiswas  Bug #2924115. Removed if then else statements for Validate_Act_Rsc_Record
-- 24-Mar-2005 sikalyan SQL Repository BugFix 4256877
/*****************************************************************************************/

G_PACKAGE_NAME   CONSTANT   VARCHAR2(30)   :='AMS_ActResource_PVT';
G_FILE_NAME      CONSTANT   VARCHAR2(12)   :='amsvrscb.pls';

-- Debug mode
g_debug boolean := FALSE;
g_debug boolean := TRUE;
--

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Check_Resource_Booked (
   p_act_Resource_rec    IN   act_Resource_rec_type,
   p_validation_mode     IN   VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status       OUT NOCOPY  VARCHAR2
);

-- Procedure AND function declarations.
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Create_Act_Resource
--
-- PURPOSE
--   This procedure is to create a Resource record that satisfy caller needs
--
-- HISTORY
--   02/20/2002       gmadana            created
--
/*****************************************************************************************/

PROCEDURE Create_Act_Resource
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit           IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2,
  p_act_Resource_rec IN     act_Resource_rec_type,
  x_act_resource_id  OUT NOCOPY    NUMBER
) IS

   l_api_name      CONSTANT VARCHAR2(30)     := 'Create_Act_Resource';
   l_api_version   CONSTANT NUMBER           := 1.0;
   l_full_name     CONSTANT VARCHAR2(60)     := G_PACKAGE_NAME || '.' || l_api_name;
   l_return_status VARCHAR2(1);
   l_act_Resource_rec  act_Resource_rec_type := p_act_Resource_rec;
   l_date DATE;
   l_startdate DATE;
   l_enddate DATE;
   l_strTime  VARCHAR2(30);
   l_strDate  VARCHAR2(30);

   CURSOR C_act_resource_id IS
   SELECT ams_act_resources_s.NEXTVAL
   FROM dual;

   CURSOR c_get_object_date(id_in IN NUMBER, type_in IN VARCHAR2) is
   SELECT start_date_time FROM ams_agendas_b
   WHERE agenda_id = id_in
   AND agenda_type = type_in;

   CURSOR c_get_sys_stat_code(id_in IN NUMBER) is
   SELECT system_status_code FROM ams_user_statuses_v
   WHERE user_status_id = id_in;

 BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_Act_Resource_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PACKAGE_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;
   if (l_act_Resource_rec.arc_act_resource_used_by = 'SESSION')
   THEN
        OPEN c_get_object_date(l_act_Resource_rec.act_resource_used_by_id, l_act_Resource_rec.arc_act_resource_used_by);
        FETCH c_get_object_date into l_date;
        CLOSE c_get_object_date;

        l_strDate := TO_CHAR(l_date, 'DD-MON-RRRR');
        l_strTime := TO_CHAR(l_act_Resource_rec.start_date_time, 'HH24:MI');
        l_strDate := l_strDate || ' ' || l_strTime;
        l_startdate := TO_DATE (l_strDate, 'DD-MM-YYYY HH24:MI');
        l_act_Resource_rec.start_date_time := l_startdate;
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message('l_start_date ' ||to_char(l_startdate,'DD-MON-RRRR HH24:MI'));
        END IF;

        l_strDate := NULL;
        l_strTime := NULL;
        l_strDate := TO_CHAR(l_date, 'DD-MON-RRRR');
        l_strTime := TO_CHAR(l_act_Resource_rec.end_date_time, 'HH24:MI');
        l_strDate := l_strDate ||' '|| l_strTime;
        l_enddate := TO_DATE (l_strDate, 'DD-MM-YYYY HH24:MI');
        l_act_Resource_rec.end_date_time := l_enddate;
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message('l_end_date ' ||to_char(l_enddate,'DD-MON-RRRR HH24:MI'));
        END IF;


        IF (AMS_DEBUG_HIGH_ON) THEN





            AMS_Utility_PVT.debug_message('l_start_date ' ||to_char(l_startdate,'DD-MON-RRRR HH24:MI'));


        END IF;
   END IF;

   OPEN c_get_sys_stat_code(l_act_Resource_rec.user_status_id);
   FETCH c_get_sys_stat_code into l_act_Resource_rec.system_status_code;
   CLOSE c_get_sys_stat_code;

   Validate_Act_Resource
   (  p_api_version          => 1.0
     ,p_init_msg_list        => p_init_msg_list
     ,p_validation_level     => p_validation_level
     ,x_return_status        => l_return_status
     ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data
     ,p_act_Resource_rec     => l_act_Resource_rec
   );

   IF l_return_status = FND_API.G_RET_STS_ERROR
   THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

----------------------------create----------------------------
   -- Get ID for activity delivery method FROM sequence.
   OPEN c_act_resource_id;
   FETCH c_act_resource_id INTO l_act_Resource_rec.activity_resource_id;
   CLOSE c_act_resource_id;



   INSERT INTO AMS_ACT_RESOURCES
   (
      activity_resource_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      act_resource_used_by_id,
      arc_act_resource_used_by,
      resource_id,
      role_cd,
      user_status_id,
      SYSTEM_STATUS_CODE,
      start_date_time,
      end_date_time,
      description,
      --TOP_LEVEL_PARENT_ID
      --TOP_LEVEL_PARENT_TYPE
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
      attribute15
   )
   VALUES
   (
      l_act_resource_rec.activity_resource_id,
      sysdate,
      FND_GLOBAL.User_Id,
      sysdate,
      FND_GLOBAL.User_Id,
      FND_GLOBAL.Conc_Login_Id,
      1,  -- object_version_number
      l_act_Resource_rec.act_resource_used_by_id,
      l_act_Resource_rec.arc_act_resource_used_by,
      l_act_Resource_rec.resource_id,
      l_act_Resource_rec.role_cd,
      l_act_resource_rec.user_status_id,
      l_act_resource_rec.system_status_code,
      l_act_resource_rec.start_date_time,
      l_act_resource_rec.end_date_time,
      l_act_resource_rec.description,
      --l_act_resource_rec.top_level_parent_id,
      --l_act_resource_rec.top_level_parent_type,
      l_act_Resource_rec.attribute_category,
      l_act_Resource_rec.attribute1,
      l_act_Resource_rec.attribute2,
      l_act_Resource_rec.attribute3,
      l_act_Resource_rec.attribute4,
      l_act_Resource_rec.attribute5,
      l_act_Resource_rec.attribute6,
      l_act_Resource_rec.attribute7,
      l_act_Resource_rec.attribute8,
      l_act_Resource_rec.attribute9,
      l_act_Resource_rec.attribute10,
      l_act_Resource_rec.attribute11,
      l_act_Resource_rec.attribute12,
      l_act_Resource_rec.attribute13,
      l_act_Resource_rec.attribute14,
      l_act_Resource_rec.attribute15
   );
   -- set OUT value
   x_act_resource_id := l_act_Resource_rec.activity_resource_id;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
       COMMIT WORK;
    END IF;
    -- Standard call to get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_AND_Get
    ( p_count     =>      x_msg_count,
      p_data      =>      x_msg_data,
      p_encoded   =>      FND_API.G_FALSE
    );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO Create_Act_Resource_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>      x_msg_count,
             p_data     =>      x_msg_data,
             p_encoded  =>      FND_API.G_FALSE
           );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        -- ROLLBACK TO Create_Act_Resource_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>      x_msg_count,
             p_data     =>      x_msg_data,
             p_encoded  =>      FND_API.G_FALSE
           );
        WHEN OTHERS THEN
           ROLLBACK TO Create_Act_Resource_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>    x_msg_count,
             p_data     =>    x_msg_data,
             p_encoded  =>    FND_API.G_FALSE
           );

END Create_Act_Resource;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Update_Act_Resource
--
-- PURPOSE
--   This procedure is to update a Resource record that satisfy caller needs
--
-- HISTORY
--   02/20/2002        gmadana            created
--
/*****************************************************************************************/

PROCEDURE Update_Act_Resource
( p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit           IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  p_act_Resource_rec IN  act_Resource_rec_type
) IS

   l_api_name         CONSTANT VARCHAR2(30)  := 'Update_Act_Resource';
   l_api_version      CONSTANT NUMBER        := 1.0;
   l_return_status    VARCHAR2(1);  -- Return value FROM procedures
   l_act_Resource_rec act_Resource_rec_type;
   l_date DATE;
   l_startdate DATE;
   l_enddate DATE;
   l_strTime  VARCHAR2(30);
   l_strDate  VARCHAR2(30);

   CURSOR c_get_object_date(id_in IN NUMBER, type_in IN VARCHAR2) is
   SELECT start_date_time FROM ams_agendas_b
   WHERE agenda_id = id_in
   AND agenda_type = type_in;

   CURSOR c_get_sys_stat_code(id_in IN NUMBER) is
   SELECT system_status_code FROM ams_user_statuses_v
   WHERE user_status_id = id_in;

  BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Act_Resource_PVT;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PACKAGE_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     complete_act_Resource_rec(
         p_act_Resource_rec,
         l_act_Resource_rec
     );

   if (l_act_Resource_rec.arc_act_resource_used_by = 'SESSION')
   THEN
   OPEN c_get_object_date(l_act_Resource_rec.act_resource_used_by_id, l_act_Resource_rec.arc_act_resource_used_by);
   FETCH c_get_object_date into l_date;
   CLOSE c_get_object_date;

   l_strDate := TO_CHAR(l_date, 'dd-mon-rrrr');
   l_strTime := TO_CHAR(l_act_Resource_rec.start_date_time, 'HH24:MI');
   l_strDate := l_strDate || ' ' || l_strTime;
   l_startdate := TO_DATE (l_strDate, 'DD-MM-YYYY HH24:MI');
   l_act_Resource_rec.start_date_time := l_startdate;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('l_start_date ' ||to_char(l_startdate,'DD-MON-RRRR HH24:MI'));
   END IF;

   l_strDate := NULL;
   l_strTime := NULL;
   l_strDate := TO_CHAR(l_date, 'dd-mon-rrrr');
   l_strTime := TO_CHAR(l_act_Resource_rec.end_date_time, 'HH24:MI');
   l_strDate := l_strDate ||' '|| l_strTime;
   l_enddate := TO_DATE (l_strDate, 'DD-MM-YYYY HH24:MI');
   l_act_Resource_rec.end_date_time := l_enddate;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('l_end_date ' ||to_char(l_enddate,'DD-MON-RRRR HH24:MI'));
   END IF;


   IF (AMS_DEBUG_HIGH_ON) THEN





       AMS_Utility_PVT.debug_message('l_start_date ' ||to_char(l_startdate,'DD-MON-RRRR HH24:MI'));


   END IF;
   end if;

   OPEN c_get_sys_stat_code(l_act_Resource_rec.user_status_id);
   FETCH c_get_sys_stat_code into l_act_Resource_rec.system_status_code;
   CLOSE c_get_sys_stat_code;


   IF (AMS_DEBUG_HIGH_ON) THEN





       AMS_Utility_PVT.debug_message(l_api_name||': check items');


   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item
   THEN
      Validate_Act_Resource_Items
      ( p_act_Resource_rec => l_act_Resource_rec,
        p_validation_mode  => JTF_PLSQL_API.g_update,
        x_return_status    => l_return_status
      );
      -- If any errors happen abort API.
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

    -- If any errors happen abort API.
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   -------------- Perform the database operation UPDATE----------------------

   update AMS_ACT_RESOURCES
   set
     last_update_date = sysdate
     ,last_updated_by =  FND_GLOBAL.User_Id
     ,last_update_login = FND_GLOBAL.Conc_Login_Id
     ,object_version_number = l_act_Resource_rec.object_version_number+1
     ,act_resource_used_by_id = l_act_resource_rec.act_resource_used_by_id
     ,arc_act_resource_used_by = l_act_resource_rec.arc_act_resource_used_by
     ,resource_id = l_act_resource_rec.resource_id
     ,role_cd = l_act_resource_rec.role_cd
     ,user_status_id = l_act_resource_rec.user_status_id
     ,system_status_code = l_act_resource_rec.system_status_code
     ,start_date_time    = l_act_resource_rec.start_date_time
     ,end_date_time      = l_act_resource_rec.end_date_time
     ,description = l_act_resource_rec.description
     --,top_level_parten_id = l_act_resource_rec.top_level_parten_id
     --,top_level_parten_type = l_act_resource_rec.top_level_parten_type
     ,attribute_category = l_act_Resource_rec.attribute_category
     ,attribute1 = l_act_Resource_rec.attribute1
     ,attribute2 = l_act_Resource_rec.attribute2
     ,attribute3 = l_act_Resource_rec.attribute3
     ,attribute4 = l_act_Resource_rec.attribute4
     ,attribute5 = l_act_Resource_rec.attribute5
     ,attribute6 = l_act_Resource_rec.attribute6
     ,attribute7 = l_act_Resource_rec.attribute7
     ,attribute8 = l_act_Resource_rec.attribute8
     ,attribute9 = l_act_Resource_rec.attribute9
     ,attribute10 = l_act_Resource_rec.attribute10
     ,attribute11 = l_act_Resource_rec.attribute11
     ,attribute12 = l_act_Resource_rec.attribute12
     ,attribute13 = l_act_Resource_rec.attribute13
     ,attribute14 = l_act_Resource_rec.attribute14
     ,attribute15 = l_act_Resource_rec.attribute15
   WHERE activity_resource_id = l_act_Resource_rec.activity_resource_id
   AND object_version_number = l_act_Resource_rec.object_version_number;

   IF (SQL%NOTFOUND)
   THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean ( p_commit )
   THEN
     COMMIT WORK;
   END IF;
    -- Standard call to get message count AND IF count is 1, get message info.
   FND_MSG_PUB.Count_AND_Get
   ( p_count   =>      x_msg_count,
     p_data    =>      x_msg_data,
     p_encoded =>      FND_API.G_FALSE
   );
   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO Update_Act_Resource_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>      x_msg_count,
             p_data     =>      x_msg_data,
             p_encoded  =>      FND_API.G_FALSE
           );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO Update_Act_Resource_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>      x_msg_count,
             p_data     =>      x_msg_data,
             p_encoded  =>      FND_API.G_FALSE
           );

        WHEN OTHERS THEN
           ROLLBACK TO Update_Act_Resource_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>      x_msg_count,
             p_data     =>      x_msg_data,
             p_encoded  =>      FND_API.G_FALSE
           );

END Update_Act_Resource;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Delete_Act_Resource
--
-- PURPOSE
--   This procedure is to delete a resource record that satisfy caller needs
--
-- HISTORY
--   02/20/2002        gmadana            created
--
/*****************************************************************************************/

PROCEDURE Delete_Act_Resource
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2   := FND_API.G_FALSE,
  p_commit           IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2,
  p_act_Resource_id  IN     NUMBER,
  p_object_version   IN     NUMBER
) IS

   l_api_name          CONSTANT VARCHAR2(30)  := 'Delete_Act_Resource';
   l_api_version       CONSTANT NUMBER        := 1.0;
   l_return_status     VARCHAR2(1);
   l_act_resource_id   NUMBER := p_act_Resource_id;
   l_role_relate_id    NUMBER;


 BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Delete_Act_Resource_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PACKAGE_NAME)
   THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
   FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------- Perform the database operation---------------

    DELETE FROM ams_act_resources
    WHERE ACTIVITY_RESOURCE_ID = p_act_Resource_id
    AND p_object_version  = p_object_version;

    IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
    END IF;


     -- Standard check of p_commit.
     IF FND_API.To_Boolean ( p_commit )
     THEN
        COMMIT WORK;
     END IF;

     -- Standard call to get message count AND IF count is 1, get message info.
     FND_MSG_PUB.Count_AND_Get
     ( p_count    =>      x_msg_count,
       p_data     =>      x_msg_data,
       p_encoded  =>      FND_API.G_FALSE
     );
     EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO Delete_Act_Resource_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_AND_Get
          ( p_count      =>      x_msg_count,
            p_data       =>      x_msg_data,
            p_encoded    =>      FND_API.G_FALSE
          );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO Delete_Act_Resource_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>      x_msg_count,
             p_data     =>      x_msg_data,
             p_encoded  =>      FND_API.G_FALSE
           );

        WHEN OTHERS THEN
           ROLLBACK TO Delete_Act_Resource_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count     =>      x_msg_count,
             p_data      =>      x_msg_data,
             p_encoded   =>      FND_API.G_FALSE
           );

END Delete_Act_Resource;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Lock_Act_Resource
--
-- PURPOSE
--   This procedure is to lock a delivery method record that satisfy caller needs
--
-- HISTORY
--   02/20/2002        gmadana            created
--
/*****************************************************************************************/

PROCEDURE Lock_Act_Resource
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2,
  p_act_resource_id  IN     NUMBER,
  p_object_version   IN     NUMBER
) IS
     l_api_name           CONSTANT VARCHAR2(30)  := 'Lock_Act_Resource';
     l_api_version        CONSTANT NUMBER        := 1.0;
     l_return_status      VARCHAR2(1);
     l_act_resource_id    NUMBER;

     CURSOR c_act_resource IS
     SELECT activity_resource_id
     FROM AMS_ACT_RESOURCES
     WHERE activity_resource_id = p_act_resource_id
     AND object_version_number = p_object_version
     FOR UPDATE of activity_resource_id NOWAIT;

   BEGIN
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PACKAGE_NAME)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list )
     THEN
        FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     OPEN c_act_resource;
     FETCH c_act_resource INTO l_act_resource_id;

     IF (c_act_resource%NOTFOUND)
     THEN
        CLOSE c_act_resource;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
           FND_MESSAGE.Set_Name('AMS', 'AMS_API_RECORD_NOT_FOUND');
           FND_MSG_PUB.Add;
        END IF;

        RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE c_act_resource;
        --
        -- END of API body.
        --
        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count    =>   x_msg_count,
          p_data     =>   x_msg_data,
          p_encoded  =>   FND_API.G_FALSE
        );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_AND_Get
         ( p_count    =>   x_msg_count,
           p_data     =>   x_msg_data,
           p_encoded  =>   FND_API.G_FALSE
         );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_AND_Get
         ( p_count    =>   x_msg_count,
           p_data     =>   x_msg_data,
           p_encoded  =>   FND_API.G_FALSE
         );
        WHEN AMS_Utility_PVT.resource_locked THEN
          x_return_status := FND_API.g_ret_sts_error;
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
             FND_MSG_PUB.add;
          END IF;

          FND_MSG_PUB.Count_AND_Get
                ( p_count    =>    x_msg_count,
                  p_data     =>    x_msg_data,
                  p_encoded  =>    FND_API.G_FALSE
                );
        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
           END IF;

          FND_MSG_PUB.Count_AND_Get
          ( p_count    =>   x_msg_count,
            p_data     =>   x_msg_data,
            p_encoded  =>   FND_API.G_FALSE
          );
END Lock_Act_Resource;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Resource
--
-- PURPOSE
--   This procedure is to validate an activity resource record
--
-- HISTORY
--   02/20/2002        gmadana            created
--
/*****************************************************************************************/

PROCEDURE Validate_Act_Resource
( p_api_version       IN     NUMBER,
  p_init_msg_list     IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level  IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY    VARCHAR2,
  x_msg_count         OUT NOCOPY    NUMBER,
  x_msg_data          OUT NOCOPY    VARCHAR2,
  p_act_Resource_rec  IN     act_Resource_rec_type
) IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'Validate_Act_Resource';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60)  := G_PACKAGE_NAME || '.' || l_api_name;
   l_return_status  VARCHAR2(1);
   l_act_Resource_rec          act_Resource_rec_type := p_act_Resource_rec;
   l_default_act_resource_rec  act_Resource_rec_type;
   l_act_resource_id    NUMBER;


  BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PACKAGE_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name||': check items');

   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item
   THEN
      Validate_Act_Resource_Items
      ( p_act_Resource_rec => l_act_Resource_rec,
        p_validation_mode  => JTF_PLSQL_API.g_create,
        x_return_status    => l_return_status
      );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

  -- Perform cross attribute validation AND missing attribute checks. Record
  -- level validation.
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': check record level');
   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record
   THEN
      Validate_Act_Rsc_Record(
        p_act_Resource_rec       => l_act_Resource_rec,
        x_return_status           => l_return_status
      );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_AND_Get
          ( p_count    =>    x_msg_count,
            p_data     =>    x_msg_data,
            p_encoded  =>    FND_API.G_FALSE
          );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>   x_msg_count,
             p_data     =>   x_msg_data,
             p_encoded  =>   FND_API.G_FALSE
           );
        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
          END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>    x_msg_count,
             p_data     =>    x_msg_data,
             p_encoded  =>    FND_API.G_FALSE
           );
END Validate_Act_Resource;

/*****************************************************************************************/
-- PROCEDURE
--    check_Act_Rsc_uk_items
--
-- HISTORY
--    02/20/2002  gmadana  Created.
/*****************************************************************************************/
PROCEDURE check_Act_Rsc_uk_items(
   p_act_Resource_rec        IN  act_Resource_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
   l_dummy NUMBER;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- For create_act_resource, when activity_resource_id is passed in, we need to
   -- check if this activity_resource_id is unique.

    IF p_validation_mode = JTF_PLSQL_API.g_create
    AND p_act_Resource_rec.activity_resource_id IS NOT NULL
    THEN
       IF AMS_Utility_PVT.check_uniqueness(
            'ams_act_resources_v',
            'activity_resource_id = ' || p_act_Resource_rec.activity_resource_id
       ) = FND_API.g_false
       THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_RES_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
       END IF;
   END IF;




END check_Act_Rsc_uk_items;

/*****************************************************************************************/
-- PROCEDURE
--    check_Act_Rsc_req_items
--
-- HISTORY
--    02/20/2002  gmadana  Created.
/*****************************************************************************************/
PROCEDURE check_Act_Rsc_req_items(
   p_act_Resource_rec  IN  act_Resource_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS

   l_coordinator_id     NUMBER;

   CURSOR c_primary_coordinator(l_session_id IN NUMBER) IS
   SELECT coordinator_id
   FROM ams_agendas_v
   WHERE agenda_id = l_session_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;


 ------------------------ user_status_id --------------------------
   IF (p_act_Resource_rec.user_status_id IS NULL OR
       p_act_Resource_rec.user_status_id = FND_API.g_miss_num)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_USER_STATUS_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   ------------------------ application_id --------------------------
 /*  IF (p_act_Resource_rec.application_id IS NULL OR
       p_act_Resource_rec.application_id = FND_API.g_miss_num)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_NO_APPLICATION_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF; */

   ------------------------ resource_id--------------------------
   IF (p_act_Resource_rec.resource_id IS NULL OR
       p_act_Resource_rec.resource_id = FND_API.g_miss_num)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_ACT_RSC_NO_RESOURCE_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ELSE
         /* The Session coordinator cannot be booked again at Resource level as
            coordinator.
          */
         OPEN  c_primary_coordinator(p_act_Resource_rec.act_resource_used_by_id);
         FETCH c_primary_coordinator INTO l_coordinator_id;
         CLOSE c_primary_coordinator;

         IF( l_coordinator_id = p_act_Resource_rec.resource_id AND p_act_Resource_rec.role_cd = 'COORDINATOR')
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_SAME_COORDINATOR_PRESENT');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
    END IF;

   ------------------------ role_cd--------------------------
   IF (p_act_Resource_rec.role_cd IS NULL OR
       p_act_Resource_rec.role_cd = FND_API.g_miss_char)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_NO_ROLE_CD');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

  ------------ ACT_RESOURCE_USED_BY_ID -------------------------------------
  IF  (p_act_Resource_rec.act_resource_used_by_id = FND_API.G_MISS_NUM OR
       p_act_Resource_rec.act_resource_used_by_id IS NULL)
  THEN
    IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
         FND_MESSAGE.set_name('AMS', 'AMS_ACT_RSC_NO_USEDBYID');
         FND_MSG_PUB.add;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  ------------ ACT_RESOURCE_USED_BY_ -------------------------------------
   IF (p_act_Resource_rec.ARC_ACT_RESOURCE_USED_BY = FND_API.G_MISS_CHAR OR
      p_act_Resource_rec.ARC_ACT_RESOURCE_USED_BY IS NULL)
   THEN
    -- missing required fields
    IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN -- MMSG
         FND_MESSAGE.set_name('AMS', 'AMS_ACT_RSC_NO_USEDBY');
         FND_MSG_PUB.add;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- If any error happens abort API.
    RETURN;
   END IF;


END check_Act_Rsc_req_items;


/*****************************************************************************************/
-- PROCEDURE
--    check_Act_Rsc_fk_items
--
-- HISTORY
--    02/20/2002  gmadana  Created.
/*****************************************************************************************/
PROCEDURE check_Act_Rsc_fk_items(
   p_act_Resource_rec  IN  act_Resource_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                NUMBER;
   l_additional_where_clause     VARCHAR2(4000);
   l_where_clause VARCHAR2(80) := NULL;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;


   /*--------------------- application_id ------------------------
   IF p_act_Resource_rec.application_id <> FND_API.g_miss_num AND
      p_act_Resource_rec.application_id is NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_application',
            'application_id',
             p_act_Resource_rec.application_id
      ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_APP_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF; */

  ----------------------- user_status_id ------------------------
   IF p_act_Resource_rec.user_status_id <> FND_API.g_miss_num
    AND p_act_Resource_rec.user_status_id IS NOT NULL THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_user_statuses_b',
            'user_status_id',
            p_act_Resource_rec.user_status_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_USER_ST_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------- RESOURCE_ID -------------------------
   IF p_act_Resource_rec.resource_id <> FND_API.g_miss_num
   THEN
      l_table_name := 'HZ_PARTIES';
      l_pk_name    := 'PARTY_ID';
      l_pk_value := p_act_Resource_rec.resource_id;
      IF AMS_Utility_PVT.Check_FK_Exists (
         p_table_name   => l_table_name
        ,p_pk_name      => l_pk_name
        ,p_pk_value     => l_pk_value
      ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_RSC_BAD_RESOURCE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- If any errors happen abort API/Procedure.
         RETURN;
      END IF;  -- check_fk_exists
   END IF;

   ---------- ACT_RESOURCE_USED_BY_ID-----------------------------
   IF p_act_resource_rec.ACT_RESOURCE_USED_BY_ID <> FND_API.g_miss_num
   THEN
      IF p_act_Resource_rec.arc_act_resource_used_by ='SESSION'
      THEN
           l_table_name := 'AMS_AGENDAS_B';
           l_pk_name    := 'AGENDA_ID';
      ELSIF (p_act_Resource_rec.arc_act_resource_used_by = 'EVEO' OR p_act_Resource_rec.arc_act_resource_used_by = 'EONE')
      THEN
           l_table_name := 'AMS_EVENT_OFFERS_ALL_B';
           l_pk_name    := 'EVENT_OFFER_ID';
      END IF;

      l_pk_value := p_act_Resource_rec.act_resource_used_by_id;
      IF AMS_Utility_PVT.Check_FK_Exists (
         p_table_name  => l_table_name
        ,p_pk_name     => l_pk_name
        ,p_pk_value    => l_pk_value
      ) = FND_API.G_FALSE
      THEN
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_RSC_INVALID_REFERENCE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- If any errors happen abort API/Procedure.
         RETURN;
      END IF;  -- check_fk_exists
   END IF;

END check_Act_Rsc_fk_items;

/*****************************************************************************************/
-- PROCEDURE
--    check_Act_Rsc_lookup_items
--
-- HISTORY
--    02/20/2002  gmadana  Created.
/*****************************************************************************************/
PROCEDURE check_Act_Rsc_lookup_items(
   p_act_Resource_rec  IN  act_Resource_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- role_code ------------------------
   IF p_act_Resource_rec.role_cd <> FND_API.g_miss_char
      AND p_act_Resource_rec.role_cd IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_ROLE',
            p_lookup_code => p_act_Resource_rec.role_cd
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_BAD_ROLE_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

    ----------------------- status ------------------------
   IF p_act_Resource_rec.system_status_code <> FND_API.g_miss_char
      AND p_act_Resource_rec.system_status_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_AGENDA_STATUS',
            p_lookup_code => p_act_Resource_rec.system_status_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVENT_BAD_USER_STATUS');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------  ARC_ACT_RESOURCE_USED_BY ------------
   IF p_act_Resource_rec.ARC_ACT_RESOURCE_USED_BY <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_SYS_ARC_QUALIFIER',
            p_lookup_code => p_act_Resource_rec.ARC_ACT_RESOURCE_USED_BY
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_ACT_RSC_BAD_SYS_ARC');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


END check_Act_Rsc_lookup_items;


/*****************************************************************************************/
-- PROCEDURE
--    check_Act_Rsc_flag_items
--
-- HISTORY
--    02/20/2002  gmadana  Created
/*****************************************************************************************/

PROCEDURE check_Act_Rsc_flag_items(
   p_act_Resource_rec    IN  act_Resource_rec_type,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   ----------------------- primary_flag ------------------------
 /*  IF p_act_Resource_rec.primary_flag <> FND_API.g_miss_char
      AND p_act_Resource_rec.primary_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_act_Resource_rec.primary_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_OBJ_BAD_PRIMARY_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF; */


END check_Act_Rsc_flag_items;

/*****************************************************************************************/
--
-- NAME
--   Validate_Act_Resource_Items
--
-- PURPOSE
--   This procedure is to validate Resource items
--
/*****************************************************************************************/

PROCEDURE Validate_Act_Resource_Items
( p_act_Resource_rec   IN    act_Resource_rec_type,
  p_validation_mode    IN    VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status      OUT NOCOPY   VARCHAR2
) IS

   l_table_name   VARCHAR2(30);
   l_pk_name      VARCHAR2(30);
   l_pk_value     VARCHAR2(30);
   l_where_clause VARCHAR2(2000);
   l_start_date   DATE;
   l_end_date     DATE;
   l_resource_id  NUMBER;
   l_res_start_date     DATE;
   l_res_end_date       DATE;
   l_parent_start_date  DATE;
   l_parent_end_date    DATE;
   l_event_start_date   DATE;
   l_event_end_date     DATE;
   l_count              NUMBER;

   /* Commented Out
   l_res_start_time     DATE;
   l_res_end_time       DATE;
   l_parent_start_time  DATE;
   l_parent_end_time    DATE;
   */

   CURSOR get_session_date (id_in in NUMBER,type_in IN VARCHAR2)is
   SELECT start_date_time, end_date_time
   FROM   AMS_agendas_b
   WHERE  agenda_id = id_in
   AND    agenda_TYPE = type_in;

   CURSOR get_event_date (id_in in NUMBER,type_in IN VARCHAR2)is
   SELECT event_start_date_time, event_end_date_time
   FROM   ams_event_offers_all_b
   WHERE  event_offer_id = id_in
   AND    event_object_type = type_in;

   CURSOR c_event_status IS
   SELECT count(event_offer_id)
   FROM  ams_event_offers_all_b
   WHERE system_status_code IN ('COMPLETED', 'CANCELLED', 'ON_HOLD','ARCHIVED','CLOSED')
   AND event_offer_id = p_act_Resource_rec.act_resource_used_by_id;

   CURSOR c_parent_status IS
   SELECT count(event_offer_id)
   FROM  ams_event_offers_all_b
   WHERE system_status_code IN ('COMPLETED', 'CANCELLED', 'ON_HOLD','ARCHIVED','CLOSED')
   AND event_offer_id = ( SELECT parent_id
                          FROM   ams_agendas_b
                          WHERE  agenda_id = ( SELECT parent_id
                                               FROM   ams_agendas_b
                                               WHERE  agenda_id = p_act_Resource_rec.act_resource_used_by_id));


BEGIN
      --  Initialize API/Procedure return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF(p_act_Resource_rec.arc_act_resource_used_by = 'SESSION')
   THEN
      OPEN  get_session_date(p_act_Resource_rec.act_resource_used_by_id,p_act_Resource_rec.arc_act_resource_used_by);
      FETCH get_session_date into l_parent_start_date, l_parent_end_date;
      CLOSE get_session_date;

      OPEN  c_parent_status;
      FETCH c_parent_status INTO l_count;
      CLOSE c_parent_status;

       IF(l_count > 0)
       THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
             Fnd_Message.set_name('AMS', 'AMS_NO_RESOURCE');
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE FND_API.g_exc_error;
       END IF;

       IF p_act_Resource_rec.start_date_time  < l_parent_start_date
       THEN
           FND_MESSAGE.set_name('AMS', 'AMS_RES_STTIME_LS_SES_STTIME');
           FND_MSG_PUB.add;
           RAISE FND_API.g_exc_error;
       ELSIF  p_act_Resource_rec.end_date_time  > l_parent_end_date
       THEN
          FND_MESSAGE.set_name('AMS', 'AMS_RES_EDTIME_GT_SES_EDTIME');
          FND_MSG_PUB.add;
          RAISE FND_API.g_exc_error;
       END IF;

   ELSIF(p_act_Resource_rec.arc_act_resource_used_by = 'EVEO'
         OR p_act_Resource_rec.arc_act_resource_used_by = 'EONE')
   THEN
      OPEN  get_event_date(p_act_Resource_rec.act_resource_used_by_id,p_act_Resource_rec.arc_act_resource_used_by);
      FETCH get_event_date into l_parent_start_date, l_parent_end_date;
      CLOSE get_event_date;

      OPEN  c_event_status;
      FETCH c_event_status INTO l_count;
      CLOSE c_event_status;

       IF(l_count > 0)
       THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
             Fnd_Message.set_name('AMS', 'AMS_NO_RESOURCE');
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE FND_API.g_exc_error;
       END IF;

      l_res_start_date := TO_DATE(TO_CHAR(p_act_Resource_rec.start_date_time,'DD:MM:YYYY'),'DD:MM:YYYY');
      l_res_end_date   := TO_DATE(TO_CHAR(p_act_Resource_rec.end_date_time,'DD:MM:YYYY'),'DD:MM:YYYY');
      l_start_date := TO_DATE(TO_CHAR(l_parent_start_date,'DD:MM:YYYY'),'DD:MM:YYYY');
      l_end_date := TO_DATE(TO_CHAR(l_parent_end_date,'DD:MM:YYYY'),'DD:MM:YYYY');

      IF l_res_start_date < l_start_date
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
             FND_MESSAGE.set_name('AMS', 'AMS_RES_SD_GT_PRNT_SD');
             FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      ELSIF l_res_start_date > l_end_date
      THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
          THEN
             FND_MESSAGE.set_name('AMS', 'AMS_RES_SD_ST_PRNT_ED');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      ELSIF l_res_start_date = l_start_date
      THEN
           IF ( TO_CHAR(p_act_Resource_rec.start_date_time,'HH24:MI') <> '00:00'
                AND
                TO_CHAR(l_parent_start_date,'HH24:MI') <> '00:00'
                AND p_act_Resource_rec.start_date_time  < l_parent_start_date )
           THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('AMS', 'AMS_RES_STTIME_LS_EVN_STTIME');
                  FND_MSG_PUB.add;
               END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
           END IF;
      END IF;

      IF l_res_end_date < l_start_date
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_RES_ED_GT_PRNT_SD');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      ELSIF l_res_end_date  > l_end_date
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_RES_ED_LT_PRNT_ED');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      ELSIF l_res_end_date = l_end_date
      THEN
          IF (TO_CHAR(p_act_Resource_rec.end_date_time,'HH24:MI') <> '00:00'
              AND
              TO_CHAR(l_parent_end_date,'HH24:MI') <> '00:00'
              AND  p_act_Resource_rec.end_date_time  > l_parent_end_date)
          THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
             THEN
                FND_MESSAGE.set_name('AMS', 'AMS_RES_EDTIME_GT_EVN_EDTIME');
                FND_MSG_PUB.add;
             END IF;
             x_return_status := FND_API.g_ret_sts_error;
             RETURN;
          END IF;
      END IF;

   END IF;


   /* Commented OUT NOCOPY
   l_res_start_time := TO_DATE(TO_CHAR(p_act_Resource_rec.start_date_time,'HH24:MI'),'HH24:MI');
   l_res_end_time := TO_DATE(TO_CHAR(p_act_Resource_rec.end_date_time,'HH24:MI'),'HH24:MI');
   l_parent_start_time := TO_DATE(TO_CHAR(l_event_start_date,'HH24:MI'),'HH24:MI');
   l_parent_end_time := TO_DATE(TO_CHAR(l_event_end_date,'HH24:MI'),'HH24:MI');
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Resource Start Time' || TO_CHAR(l_res_start_time,'DD-MM-YYYY HH24:MI')  );
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Resource End Time' || TO_CHAR(l_res_end_time,'DD-MM-YYYY HH24:MI') );
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Parent Start Time' || TO_CHAR(l_parent_start_time,'DD-MM-YYYY HH24:MI') || TO_CHAR(l_event_start_date,'DD-MM-YYYY HH24:MI'));
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Parent End Time' || TO_CHAR(l_parent_End_time,'DD-MM-YYYY HH24:MI') || TO_CHAR(l_event_end_date,'DD-MM-YYYY HH24:MI'));
   END IF;
   */


   --------------------------------------Create mode--------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Checking uk_items');
   END IF;
   check_Act_Rsc_uk_items(
      p_act_Resource_rec  => p_act_Resource_rec,
      p_validation_mode   => p_validation_mode,
      x_return_status     => x_return_status
   );

   -------------------------- Create or Update Mode ----------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Checking req_items');
   END IF;
   check_Act_Rsc_req_items(
      p_act_Resource_rec  => p_act_Resource_rec,
      x_return_status     => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Checking fk_items');

  END IF;
  check_Act_Rsc_fk_items(
      p_act_Resource_rec => p_act_Resource_rec,
      x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_UTILITY_PVT.debug_message('Checking lookup_items');

   END IF;
   check_Act_Rsc_lookup_items(
      p_act_Resource_rec => p_act_Resource_rec,
      x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_UTILITY_PVT.debug_message('Checking flag_items');

   END IF;
   check_Act_Rsc_flag_items(
      p_act_Resource_rec => p_act_Resource_rec,
      x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   /* The End Time has to be greater than Start Time */
   IF ( p_act_Resource_rec.start_date_time > p_act_Resource_rec.end_date_time)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
       THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EDTIME_LS_STTIME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_UTILITY_PVT.debug_message('Checking Resource is already booked');

   END IF;
   check_Resource_booked(
      p_act_Resource_rec => p_act_Resource_rec,
      p_validation_mode  => p_validation_mode,
      x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


END Validate_Act_Resource_Items;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Rsc_Record
--
-- PURPOSE
--   This procedure is to validate resource record
--
-- NOTES
--
/*****************************************************************************************/

PROCEDURE Validate_Act_Rsc_Record(
  p_act_Resource_rec     IN   act_Resource_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
) IS

   l_api_name        CONSTANT VARCHAR2(30)  := 'Validate_Act_Rsc_Record';
   l_api_version     CONSTANT NUMBER        := 1.0;
   l_return_status   VARCHAR2(1);
   l_count NUMBER := 0;

  BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        l_api_version,
                                        l_api_name,
                                        G_PACKAGE_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

/* dbiswas commented out the following section of if then else code for bug 2924115 on 28-Apr-2003
   IF (p_act_Resource_rec.role_cd = 'COORDINATOR' AND
       p_act_Resource_rec.system_status_code = 'CONFIRMED')
   THEN
        BEGIN

           SELECT 1 into l_count
           FROM   ams_act_resources_v
           WHERE  act_resource_used_by_id  =  p_act_Resource_rec.act_resource_used_by_id
           AND arc_act_resource_used_by  =  p_act_Resource_rec.arc_act_resource_used_by
           AND resource_id  =  p_act_Resource_rec.resource_id
           AND system_status_code = 'CONFIRMED'
         --  AND system_status_code  =  p_act_Resource_rec.system_status_code
           AND
           (start_date_time  BETWEEN  p_act_Resource_rec.start_date_time AND  p_act_Resource_rec.end_date_time
             OR
            end_date_time  BETWEEN  p_act_Resource_rec.start_date_time AND  p_act_Resource_rec.end_date_time
             OR
            p_act_Resource_rec.start_date_time  BETWEEN  start_date_time AND  end_date_time);

           EXCEPTION
           WHEN NO_DATA_FOUND THEN
           l_count := 0;

        END;

        IF l_count > 0
        THEN
           IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error)
           THEN
              FND_MESSAGE.set_name ('AMS', 'AMS_SAME_COORDINATOR_PRESENT');
              FND_MSG_PUB.add;
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;

       ELSE
           x_return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;

   END IF;
   end update by dbiswas on Apr 28, 2003
*/
           x_return_status := FND_API.G_RET_STS_SUCCESS;


END Validate_Act_Rsc_Record;

/*****************************************************************************************/
-- PROCEDURE
--    init_Act_Rsc_Record
--
-- HISTORY
--    02/20/2002  gmadana  Create.
/*****************************************************************************************/
PROCEDURE init_Act_Rsc_Record(
   x_act_Resource_rec  OUT NOCOPY  act_Resource_rec_type
)
IS
BEGIN

   x_act_Resource_rec.act_resource_used_by_id   := FND_API.g_miss_num;
   x_act_Resource_rec.arc_act_resource_used_by  := FND_API.g_miss_char;
   x_act_Resource_rec.resource_id               := FND_API.g_miss_num;
   x_act_Resource_rec.role_cd                   := FND_API.g_miss_char;
   x_act_Resource_rec.user_status_id            := FND_API.g_miss_num;
   x_act_Resource_rec.system_status_code        := FND_API.g_miss_char;
   x_act_Resource_rec.start_date_time           := FND_API.g_miss_date;
   x_act_Resource_rec.end_date_time             := FND_API.g_miss_date;
   x_act_Resource_rec.last_update_date          := FND_API.g_miss_date;
   x_act_Resource_rec.last_updated_by           := FND_API.g_miss_num;
   x_act_Resource_rec.creation_date             := FND_API.g_miss_date;
   x_act_Resource_rec.created_by                := FND_API.g_miss_num;
   x_act_Resource_rec.last_update_login         := FND_API.g_miss_num;
   x_act_Resource_rec.object_version_number     := FND_API.g_miss_num;
   --p_act_Resource_rec.application_id          := FND_API.g_miss_num;
   x_act_Resource_rec.description               := FND_API.g_miss_char;
   --x_act_Resource_rec.top_level_parten_id       := FND_API.g_miss_num;
   --x_act_Resource_rec.top_level_parent_type     := FND_API.g_miss_char;
   x_act_Resource_rec.attribute_category        := FND_API.g_miss_char;
   x_act_Resource_rec.attribute1                := FND_API.g_miss_char;
   x_act_Resource_rec.attribute2                := FND_API.g_miss_char;
   x_act_Resource_rec.attribute3                := FND_API.g_miss_char;
   x_act_Resource_rec.attribute4                := FND_API.g_miss_char;
   x_act_Resource_rec.attribute5                := FND_API.g_miss_char;
   x_act_Resource_rec.attribute6                := FND_API.g_miss_char;
   x_act_Resource_rec.attribute7                := FND_API.g_miss_char;
   x_act_Resource_rec.attribute8                := FND_API.g_miss_char;
   x_act_Resource_rec.attribute9                := FND_API.g_miss_char;
   x_act_Resource_rec.attribute10               := FND_API.g_miss_char;
   x_act_Resource_rec.attribute11               := FND_API.g_miss_char;
   x_act_Resource_rec.attribute12               := FND_API.g_miss_char;
   x_act_Resource_rec.attribute13               := FND_API.g_miss_char;
   x_act_Resource_rec.attribute14               := FND_API.g_miss_char;
   x_act_Resource_rec.attribute15               := FND_API.g_miss_char;

END init_Act_Rsc_Record;


PROCEDURE complete_act_Resource_rec(
   p_act_Resource_rec  IN    act_Resource_rec_type,
   x_act_Resource_rec  OUT NOCOPY   act_Resource_rec_type
) IS
   CURSOR c_resource IS
   SELECT *
   FROM ams_act_resources
   WHERE activity_resource_id = p_act_Resource_rec.activity_resource_id;
   l_act_Resource_rec c_resource%ROWTYPE;

BEGIN
   x_act_Resource_rec  :=  p_act_Resource_rec;

   OPEN c_resource;
   FETCH c_resource INTO l_act_Resource_rec;
   IF c_resource%NOTFOUND THEN
   CLOSE c_resource;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_resource;

  /* IF p_act_Resource_rec.application_id = FND_API.g_miss_num THEN
        x_act_Resource_rec.application_id := l_act_Resource_rec.application_id;
   END IF; */

   IF p_act_Resource_rec.created_by = FND_API.g_miss_num THEN
      x_act_Resource_rec.created_by := l_act_Resource_rec.created_by;
   END IF;

   IF p_act_Resource_rec.creation_date = FND_API.g_miss_date THEN
      x_act_Resource_rec.creation_date := l_act_Resource_rec.creation_date;
   END IF;

   IF p_act_Resource_rec.last_updated_by = FND_API.g_miss_num THEN
      x_act_Resource_rec.last_updated_by := l_act_Resource_rec.last_updated_by;
   END IF;

   IF p_act_Resource_rec.last_update_date = FND_API.g_miss_date THEN
      x_act_Resource_rec.last_update_date := l_act_Resource_rec.last_update_date;
   END IF;


   IF p_act_Resource_rec.act_resource_used_by_id = FND_API.g_miss_num THEN
      x_act_Resource_rec.act_resource_used_by_id :=l_act_Resource_rec.act_resource_used_by_id;
   END IF;

   IF p_act_Resource_rec.arc_act_resource_used_by = FND_API.g_miss_char THEN
      x_act_Resource_rec.arc_act_resource_used_by := l_act_Resource_rec.arc_act_resource_used_by;
   END IF;

   IF p_act_Resource_rec.resource_id = FND_API.g_miss_num THEN
      x_act_Resource_rec.resource_id := l_act_Resource_rec.resource_id;
   END IF;

   IF p_act_Resource_rec.role_cd = FND_API.g_miss_char THEN
      x_act_Resource_rec.role_cd := l_act_Resource_rec.role_cd;
   END IF;


   IF p_act_Resource_rec.user_status_id = FND_API.g_miss_num THEN
      x_act_Resource_rec.user_status_id := l_act_Resource_rec.user_status_id;
   END IF;

   IF p_act_Resource_rec.system_status_code = FND_API.g_miss_char THEN
      x_act_Resource_rec.system_status_code := l_act_Resource_rec.system_status_code;
   END IF;

   IF p_act_Resource_rec.start_date_time = FND_API.g_miss_date THEN
      x_act_Resource_rec.start_date_time := l_act_Resource_rec.start_date_time;
   END IF;

   IF p_act_Resource_rec.end_date_time = FND_API.g_miss_date THEN
      x_act_Resource_rec.end_date_time := l_act_Resource_rec.end_date_time;
   END IF;


   IF p_act_Resource_rec.description = FND_API.g_miss_char THEN
      x_act_Resource_rec.description := l_act_Resource_rec.description;
   END IF;

/*   IF p_act_Resource_rec.top_level_parten_id = FND_API.g_miss_num THEN
      x_act_Resource_rec.top_level_parten_id := l_act_Resource_rec.top_level_parten_id;
   END IF;

   IF p_act_Resource_rec.top_level_parten_type = FND_API.g_miss_char THEN
      x_act_Resource_rec.top_level_parten_type := l_act_Resource_rec.top_level_parten_type;
   END IF;
*/
   IF p_act_Resource_rec.attribute_category = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute_category := l_act_Resource_rec.attribute_CATEGORY;
   END IF;

   IF p_act_Resource_rec.attribute1 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute1 := l_act_Resource_rec.attribute1;
   END IF;

   IF p_act_Resource_rec.attribute2 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute2 := l_act_Resource_rec.attribute2;
   END IF;

   IF p_act_Resource_rec.attribute3 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute3 := l_act_Resource_rec.attribute3;
   END IF;

   IF p_act_Resource_rec.attribute4 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute4 := l_act_Resource_rec.attribute4;
   END IF;

   IF p_act_Resource_rec.attribute5 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute5 := l_act_Resource_rec.attribute5;
   END IF;

   IF p_act_Resource_rec.attribute6 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute6 := l_act_Resource_rec.attribute6;
   END IF;

   IF p_act_Resource_rec.attribute7 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute7 := l_act_Resource_rec.attribute7;
   END IF;

   IF p_act_Resource_rec.attribute8 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute8 := l_act_Resource_rec.attribute8;
   END IF;

   IF p_act_Resource_rec.attribute9 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute9 := l_act_Resource_rec.attribute9;
   END IF;

   IF p_act_Resource_rec.attribute10 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute10 := l_act_Resource_rec.attribute10;
   END IF;

   IF p_act_Resource_rec.attribute11 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute11 := l_act_Resource_rec.attribute11;
   END IF;

   IF p_act_Resource_rec.attribute11 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute11 := l_act_Resource_rec.attribute11;
   END IF;

   IF p_act_Resource_rec.attribute12 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute12 := l_act_Resource_rec.attribute12;
   END IF;

   IF p_act_Resource_rec.attribute13 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute13 := l_act_Resource_rec.attribute13;
   END IF;

   IF p_act_Resource_rec.attribute14 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute14 := l_act_Resource_rec.attribute14;
   END IF;

   IF p_act_Resource_rec.attribute15 = FND_API.g_miss_char THEN
      x_act_Resource_rec.attribute15 := l_act_Resource_rec.attribute15;
   END IF;

END complete_act_Resource_rec;


/*****************************************************************************************/
--   Check_Resource_Booked
--   02/22/2002      gmadana     created.
--
--   This Procedure checks whether the requested resource is already booked.
--   If we are adding resource for a Session, then we have to check whether
--   that resource is added to any Session (all across) or to  any Event other
--   than the event for which that session is created.
--   If we are updating resource for a Session, then we have to check whether
--   that resource is added to any Session (all across except itself) or to
--   any Event other than the event for which that session is created.
--   If we are adding a resouce to EVEO/EONE, then you have to check whether that
--   resource is attached to any Event (all across) or to any Sessions which are
--   created for other Events than itself
--   If we are updating a resouce to EVEO/EONE, then you have to check whether that
--   resource is attached to any Event (all across except itself) or to any Sessions
--   which are  created for other Events than itself
/*****************************************************************************************/

PROCEDURE Check_Resource_Booked (
   p_act_Resource_rec IN  act_Resource_rec_Type,
   p_validation_mode  IN  VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
)
IS
   l_start_date   DATE;
   l_end_date     DATE;
   l_track_id     NUMBER;
   l_event_id     NUMBER;
   l_session_id   NUMBER;
   l_count        NUMBER := 0;
   l_event_type   VARCHAR2(15);


   CURSOR C_check_sessions_create(id_in IN NUMBER) IS
   SELECT count(*)
   FROM ams_act_resources
   WHERE resource_id = id_in
   AND arc_act_resource_used_by = 'SESSION'
   AND system_status_code = 'CONFIRMED'
   AND role_cd <> 'COORDINATOR'
   AND( p_act_Resource_rec.start_date_time BETWEEN start_date_time AND end_date_time
   OR  p_act_Resource_rec.end_date_time BETWEEN start_date_time AND end_date_time
   OR  start_date_time BETWEEN  p_act_Resource_rec.start_date_time AND p_act_Resource_rec.end_date_time);

   CURSOR C_check_sessions_update IS
   SELECT count(*)
   FROM ams_act_resources
   WHERE resource_id = p_act_Resource_rec.resource_id
   AND activity_resource_id <> p_act_Resource_rec.activity_resource_id
   AND arc_act_resource_used_by = 'SESSION'
   AND system_status_code = 'CONFIRMED'
   AND role_cd <> 'COORDINATOR'
   AND (p_act_Resource_rec.start_date_time BETWEEN start_date_time AND end_date_time
   OR  p_act_Resource_rec.end_date_time BETWEEN start_date_time AND end_date_time
   OR  start_date_time BETWEEN  p_act_Resource_rec.start_date_time AND p_act_Resource_rec.end_date_time);

   CURSOR C_check_events_session IS
   SELECT count(*)
   FROM ams_act_resources
   WHERE resource_id = p_act_Resource_rec.resource_id
   AND act_resource_used_by_id <>  ( SELECT parent_id
                                     FROM ams_agendas_b
                                     WHERE agenda_id = (SELECT parent_id
                                                        FROM ams_agendas_b
                                                        WHERE agenda_id = p_act_Resource_rec.act_resource_used_by_id))
   AND arc_act_resource_used_by IN ('EVEO', 'EONE')
   AND system_status_code = 'CONFIRMED'
   AND role_cd <> 'COORDINATOR'
   AND (p_act_Resource_rec.start_date_time BETWEEN start_date_time AND end_date_time
   OR  p_act_Resource_rec.end_date_time BETWEEN start_date_time AND end_date_time
   OR  start_date_time BETWEEN  p_act_Resource_rec.start_date_time AND p_act_Resource_rec.end_date_time);


   CURSOR C_check_events_create IS
   SELECT count(*)
   FROM ams_act_resources
   WHERE resource_id = p_act_Resource_rec.resource_id
   AND arc_act_resource_used_by IN ('EVEO', 'EONE')
   AND system_status_code = 'CONFIRMED'
   AND role_cd <> 'COORDINATOR'
   AND (p_act_Resource_rec.start_date_time BETWEEN start_date_time AND end_date_time
   OR  p_act_Resource_rec.end_date_time BETWEEN start_date_time AND end_date_time
   OR  start_date_time BETWEEN  p_act_Resource_rec.start_date_time AND p_act_Resource_rec.end_date_time);

   CURSOR C_check_events_update  IS
   SELECT count(*)
   FROM ams_act_resources
   WHERE resource_id = p_act_Resource_rec.resource_id
   AND arc_act_resource_used_by IN ('EVEO', 'EONE')
   AND activity_resource_id <> p_act_Resource_rec.activity_resource_id
   AND system_status_code = 'CONFIRMED'
   AND role_cd <> 'COORDINATOR'
   AND (p_act_Resource_rec.start_date_time BETWEEN start_date_time AND end_date_time
   OR  p_act_Resource_rec.end_date_time BETWEEN start_date_time AND end_date_time
   OR  start_date_time BETWEEN  p_act_Resource_rec.start_date_time AND p_act_Resource_rec.end_date_time);


   CURSOR C_check_other_sessions(id_in IN NUMBER) IS
   SELECT count(*)
   FROM ams_act_resources
   WHERE  arc_act_resource_used_by = 'SESSION'
   AND system_status_code = 'CONFIRMED'
   AND role_cd <> 'COORDINATOR'
   AND act_resource_used_by_id IN ( SELECT agenda_id
                                   FROM ams_agendas_b
                                   WHERE parent_id <> p_act_Resource_rec.act_resource_used_by_id
                                   AND  parent_type IN ('EVEO', 'EONE'))
   AND( p_act_Resource_rec.start_date_time BETWEEN start_date_time AND end_date_time
   OR  p_act_Resource_rec.end_date_time BETWEEN start_date_time AND end_date_time
   OR  start_date_time BETWEEN  p_act_Resource_rec.start_date_time AND p_act_Resource_rec.end_date_time);


BEGIN

  --Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    /* If we are adding Corinator, we donot check for availability */

   IF (p_act_Resource_rec.role_cd <> 'COORDINATOR' )
   THEN
      IF(p_act_Resource_rec.arc_act_resource_used_by = 'SESSION')
      THEN
          IF(p_validation_mode = Jtf_Plsql_Api.g_create)
          THEN
               /* checking across all the sessions for date overlap */
              OPEN  C_check_sessions_create(p_act_Resource_rec.resource_id);
              FETCH C_check_sessions_create INTO l_count;
              CLOSE C_check_sessions_create;
          ELSIF(p_validation_mode = Jtf_Plsql_Api.g_update)
          THEN
              /* checking across all the sessions excluding itself for date overlap */
              OPEN  C_check_sessions_update;
              FETCH C_check_sessions_update INTO l_count;
              CLOSE C_check_sessions_update;
          END IF;

          IF (AMS_DEBUG_HIGH_ON) THEN



              AMS_Utility_PVT.debug_message('The resource_id is ' || p_act_Resource_rec.resource_id);

          END IF;
          IF (AMS_DEBUG_HIGH_ON) THEN

              AMS_Utility_PVT.debug_message('The count for sessions/SESSION is ' || l_count);
          END IF;
          /* If l_count > 0 i.e. there are some existing sessions with date overlap.
             So Error out.
          */
          IF (l_count > 0)
          THEN
             x_return_status := Fnd_Api.g_ret_sts_error;
             GOTO ERROR;
          END IF;

          /* If there are no sessions with date overlap, then check all
             the events excluding its parent event for date overlap
          */
          OPEN  C_check_events_session;
          FETCH C_check_events_session INTO l_count;
          CLOSE C_check_events_session;

          IF (AMS_DEBUG_HIGH_ON) THEN



              AMS_Utility_PVT.debug_message('The count for events/SESSION is ' || l_count);

          END IF;
          /* If l_count > 0 i.e. there are some existing events  with date overlap.
             So Error out.
          */
         IF (l_count > 0)
          THEN
             x_return_status := Fnd_Api.g_ret_sts_error;
             GOTO ERROR;
          END IF;

      ELSIF(p_act_Resource_rec.arc_act_resource_used_by = 'EVEO' OR
            p_act_Resource_rec.arc_act_resource_used_by = 'EONE')
      THEN
          IF(p_validation_mode = Jtf_Plsql_Api.g_create)
          THEN
              /* checking across all the events for date overlap */
              OPEN  C_check_events_create;
              FETCH C_check_events_create INTO l_count;
              CLOSE C_check_events_create;
          ELSIF(p_validation_mode = Jtf_Plsql_Api.g_update)
          THEN
              /* checking across all the events except itself, for date overlap */
              OPEN  C_check_events_update;
              FETCH C_check_events_update INTO l_count;
              CLOSE C_check_events_update;
          END IF;

          IF (AMS_DEBUG_HIGH_ON) THEN



              AMS_Utility_PVT.debug_message('The count for events/(EVEO/EONE) is ' || l_count);

          END IF;
          /* If l_count > 0 i.e. there are some existing events with date overlap.
             So Error out.
          */
         IF (l_count > 0)
          THEN
             x_return_status := Fnd_Api.g_ret_sts_error;
             GOTO ERROR;
          END IF;

          /* If there are no events with date overlap, then check all
             the sessions created for all events excluding those created for
             its parent event for date overlap.
          */
          OPEN  C_check_other_sessions(l_session_id);
          FETCH C_check_other_sessions INTO l_count;
          CLOSE C_check_other_sessions;

          IF (AMS_DEBUG_HIGH_ON) THEN



              AMS_Utility_PVT.debug_message('The count for Sessions/(EVEO/EONE) is ' || l_count);

          END IF;
          /* If l_count > 0 i.e. there are some existing sessions with date overlap.
             So Error out.
          */
          IF (l_count > 0)
          THEN
             x_return_status := Fnd_Api.g_ret_sts_error;
             GOTO ERROR;
          END IF;

      END IF; --IF(p_act_Resource_rec.arc_act_resource_used_by = 'SESSION')

      <<ERROR>>
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error)
      THEN
         IF( x_return_status = Fnd_Api.g_ret_sts_error) -- to avoid flow though
         THEN
             IF (p_act_Resource_rec.arc_act_resource_used_by = 'SESSION')
             THEN
                Fnd_Message.set_name('AMS', 'AMS_SESSION_RESOURCE_BOOKED');
             ELSE
                Fnd_Message.set_name('AMS', 'AMS_RESOURCE_BOOKED');
             END IF;
             Fnd_Msg_Pub.ADD;
             RETURN;
         END IF;
      END IF;

   END IF; --(p_act_Resource_rec.role_cd <> 'COORDINATOR')

END Check_Resource_Booked;

END AMS_ActResource_PVT;

/
