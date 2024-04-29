--------------------------------------------------------
--  DDL for Package Body AMS_AGENDAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_AGENDAS_PVT" as
/*$Header: amsvagnb.pls 120.2 2005/12/29 22:49:55 sikalyan noship $*/

/*****************************************************************************************/
-- NAME  AMS_Agendas_PVT
--
-- HISTORY
-- 2/19/2002   gmadana   CREATED
-- 08/19/2002  gmadana   Sessions/Tracks cannot be created/updated/deleted
--                       for the event schedules which are cancelled/completed/
--                       archived/on_hold
-- 25-feb-2003 soagrawa  Fixed bug# 2820297
-- 28-mar-2003 soagrawa  Added add_language. Bug# 2876033
--24-Mar-2005 sikalyan SQL Repository BugFix 4256877
--30-Dec-2005   sikalyan Performance BugFix 4898041
/*****************************************************************************************/

G_PACKAGE_NAME   CONSTANT VARCHAR2(30):='AMS_Agendas_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(15):='amsvagnb.pls';

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Rollup_StTime_EdTime (
  p_agenda_rec      IN   agenda_rec_type,
  x_return_status   OUT NOCOPY  VARCHAR2
) ;

-- Procedure and function declarations.
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Create_Agenda
--
-- PURPOSE
--   This procedure is used to create a Agenda (Track/Session)
--
-- HISTORY
--   02/19/2002        gmadana           created
--   04/14/2003        anchaudh           modified to fix bug#2886784
/*****************************************************************************************/

PROCEDURE Create_Agenda
(  p_api_version      IN     NUMBER,
   p_init_msg_list    IN     VARCHAR2      := FND_API.G_FALSE,
   p_commit           IN     VARCHAR2      := FND_API.G_FALSE,
   p_validation_level IN     NUMBER        := FND_API.G_VALID_LEVEL_FULL,
   p_agenda_rec       IN     agenda_rec_type,
   x_return_status    OUT NOCOPY    VARCHAR2,
   x_msg_count        OUT NOCOPY    NUMBER,
   x_msg_data         OUT NOCOPY    VARCHAR2,
   x_agenda_id        OUT NOCOPY    NUMBER
) IS
    l_api_name        CONSTANT VARCHAR2(30)       := 'Create_Agenda';
    l_api_version     CONSTANT NUMBER             := 1.0;
    l_full_name       CONSTANT VARCHAR2(60)       := G_PACKAGE_NAME || '.' || l_api_name;
    l_return_status   VARCHAR2(1);
    l_agenda_rec      agenda_rec_type             := p_agenda_rec;
    l_track_rec       agenda_rec_type;
    l_agenda_id       NUMBER;
    l_agenda_count    NUMBER;
    l_track_id        NUMBER;
    l_event_id        NUMBER;
    l_coordinator_id  NUMBER;


   CURSOR c_agenda_seq IS
   SELECT ams_agendas_b_s.NEXTVAL
   FROM DUAL;

   CURSOR c_agenda_count(l_agenda_id IN NUMBER) IS
   SELECT count(*)
   FROM ams_agendas_v
   WHERE agenda_id = l_agenda_id;

   CURSOR c_general_track IS
   SELECT *
   FROM   ams_agendas_b
   WHERE  default_track_flag = 'Y'
   AND    active_flag  = 'Y'
   AND    parent_id = p_agenda_rec.parent_id;

   l_agenda_row      c_general_track%ROWTYPE;


   CURSOR c_event_coordinator(id_in   IN   NUMBER) IS
   SELECT coordinator_id
   FROM ams_event_offers_vl
   WHERE event_offer_id =  id_in;

   CURSOR c_event_id(id_in IN NUMBER)    IS
   SELECT parent_id
   FROM ams_agendas_v
   WHERE agenda_id = id_in ;


   CURSOR c_track_coordinator IS
   SELECT coordinator_id
   FROM   ams_agendas_v
   WHERE  agenda_id = p_agenda_rec.parent_id;

   CURSOR  c_event_timezone(id_in IN NUMBER) IS
   SELECT timezone_id
   FROM   ams_event_offers_vl
   WHERE  event_offer_id = id_in;




  BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Agenda_PVT;

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
      Validate_Agenda
      ( p_api_version            => 1.0
        ,p_init_msg_list         => p_init_msg_list
        ,p_validation_level      => p_validation_level
        ,x_return_status         => l_return_status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
        ,p_agenda_rec            => l_agenda_rec
      );
      -- If any errors happen abort API.
      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      ------Generating the seq num for agenda id------------------
      IF l_agenda_rec.agenda_id IS NULL
      THEN
         LOOP
            OPEN c_agenda_seq;
            FETCH c_agenda_seq INTO l_agenda_rec.agenda_id;
            CLOSE c_agenda_seq;

            OPEN c_agenda_count(l_agenda_rec.agenda_id);
            FETCH c_agenda_count INTO l_agenda_count;
            CLOSE c_agenda_count;

            EXIT WHEN l_agenda_count = 0;
         END LOOP;
     END IF;

      /* If we are creating a Session with no track, then we have to create
         a General Track. For General Track default track falg will be 'Y'.
         If there is no track, from the JSP page, we send event_offer_id as
         parent_id and EVEO/EONE as parent_type
       */

      IF(l_agenda_rec.agenda_type = 'SESSION')
      THEN
         IF(l_agenda_rec.parent_type = 'EVEO' OR l_agenda_rec.parent_type = 'EONE')
         THEN
            /* Get the General Track. If there is no general Track,
               Create One.
            */
            OPEN c_general_track;
            FETCH c_general_track INTO l_agenda_row;

            IF c_general_track%NOTFOUND
            THEN
               l_track_rec.agenda_name    := 'General';
               l_track_rec.agenda_type    := 'TRACK';
               l_track_rec.parent_id      := l_agenda_rec.parent_id;
               l_track_rec.parent_type    := l_agenda_rec.parent_type;
               l_track_rec.application_id := l_agenda_rec.application_id;
               l_track_rec.coordinator_id := l_agenda_rec.coordinator_id;
               l_track_rec.default_track_flag := 'Y';


                Create_Agenda
               ( p_api_version      => l_api_version,
                 p_init_msg_list    => FND_API.G_FALSE,
                 p_commit           => FND_API.G_FALSE,
                 p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                 p_agenda_rec       => l_track_rec,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 x_agenda_id        => x_agenda_id
                );

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
               THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_ERROR
               THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

               /* Replacing the parent_id and parent_type for Session */
               l_agenda_rec.parent_type := 'TRACK';
               l_agenda_rec.parent_id   := x_agenda_id;

            ELSE
               l_agenda_rec.parent_type := l_agenda_row.agenda_type;
               l_agenda_rec.parent_id   := l_agenda_row.agenda_id;

            END IF; --IF c_general_track%NOTFOUND

            CLOSE c_general_track;

         END IF; --IF(l_agenda_rec.parent_type = 'EVEO')

      END IF; --IF(l_agenda_rec.agenda_type = 'SESSION')


     /* If the coordinator_id is NULL for Session, then default it with
        that of Track. If the Coordinator_id is NULL for Track, then
        default it with that of EVEO/EONE.
     */
 --anchaudh:Start Commenting for bug#2886784.
 /*  IF(p_agenda_rec.agenda_type = 'TRACK')
   THEN
      IF(p_agenda_rec.coordinator_id is NULL)
      THEN

         OPEN  c_event_coordinator(p_agenda_rec.parent_id);
         fetch c_event_coordinator INTO l_coordinator_id;
         CLOSE c_event_coordinator;

      END IF;
   ELSIF(p_agenda_rec.agenda_type = 'SESSION')
   THEN
       IF(p_agenda_rec.coordinator_id is NULL)
       THEN

         OPEN  c_track_coordinator;
         IF c_track_coordinator%FOUND
         THEN
            fetch c_track_coordinator INTO  l_coordinator_id;
         ELSE */
            /* If track Coordinator is NULL, copy from Event Schedule */
            /* Getting the track id  and event id*/

     /*       OPEN  c_event_id(p_agenda_rec.parent_id);
            fetch c_event_id INTO l_event_id;
            CLOSE c_event_id;


            OPEN  c_event_coordinator(l_event_id);
            fetch c_event_coordinator INTO l_coordinator_id;
            CLOSE c_event_coordinator;

         END IF;
         CLOSE c_track_coordinator;

       END IF;                 --IF(p_agenda_rec.coordinator_id is NULL)
    END IF;  */               --ELSIF(p_agenda_rec.agenda_type = 'SESSION')
    --anchaudh:End Commenting for bug#2886784.


      /* If the timzone is null for Session then copy the time zone from
         event schedule
      */
      IF(l_agenda_rec.agenda_type = 'SESSION')
      THEN
          IF(l_agenda_rec.timezone_id IS NULL)
          THEN

            OPEN  c_event_id(p_agenda_rec.parent_id);
            fetch c_event_id INTO l_event_id;
            CLOSE c_event_id;

            OPEN  c_event_timezone(l_event_id);
            FETCH c_event_timezone INTO l_agenda_rec.timezone_id;
            CLOSE c_event_timezone;

          END IF;
       END IF;

      ----------------------------create----------------------------
      INSERT INTO AMS_AGENDAS_B
      (
         agenda_id,
         setup_type_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         object_version_number,
         application_id,
         agenda_type,
         room_id,
         active_flag,
         default_track_flag,
         start_date_time,
         end_date_time,
         coordinator_id,
         timezone_id,
         parent_type,
         parent_id,
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
         l_agenda_rec.agenda_id,
         l_agenda_rec.setup_type_id,
         sysdate,
         FND_GLOBAL.User_Id,
         sysdate,
         FND_GLOBAL.User_Id,
         FND_GLOBAL.Conc_Login_Id,
         1,  -- object_version_number
         l_agenda_rec.application_id,
         l_agenda_rec.agenda_type,
         l_agenda_rec.room_id,
         NVL(l_agenda_rec.active_flag, 'Y'),
         NVL(l_agenda_rec.default_track_flag, 'N'),
         l_agenda_rec.start_date_time,
         l_agenda_rec.end_date_time,
         nvl(l_agenda_rec.coordinator_id,l_coordinator_id),
         l_agenda_rec.timezone_id,

         l_agenda_rec.parent_type,
         l_agenda_rec.parent_id,

         l_agenda_rec.attribute_category,
         l_agenda_rec.attribute1,
         l_agenda_rec.attribute2,
         l_agenda_rec.attribute3,
         l_agenda_rec.attribute4,
         l_agenda_rec.attribute5,
         l_agenda_rec.attribute6,
         l_agenda_rec.attribute7,
         l_agenda_rec.attribute8,
         l_agenda_rec.attribute9,
         l_agenda_rec.attribute10,
         l_agenda_rec.attribute11,
         l_agenda_rec.attribute12,
         l_agenda_rec.attribute13,
         l_agenda_rec.attribute14,
         l_agenda_rec.attribute15
      );

      INSERT INTO ams_agendas_tl(
      agenda_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      agenda_name,
      description
   )
   SELECT
      l_agenda_rec.agenda_id,
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      l_agenda_rec.agenda_name,
      l_agenda_rec.description
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM ams_agendas_tl t
         WHERE t.agenda_id = l_agenda_rec.agenda_id
         AND t.language = l.language_code );

      -- set OUT value
      x_agenda_id := l_agenda_rec.agenda_id;

      /* Roll up the times to Track and then to Event Level */
     /* Rollup_StTime_EdTime (
         p_agenda_rec    => l_agenda_rec,
         x_return_status => x_return_status
      );

      IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF; */

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
           ROLLBACK TO Create_Agenda_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>      x_msg_count,
             p_data     =>      x_msg_data,
             p_encoded  =>      FND_API.G_FALSE
           );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO Create_Agenda_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>      x_msg_count,
             p_data     =>      x_msg_data,
             p_encoded  =>      FND_API.G_FALSE
           );

        WHEN OTHERS THEN
           ROLLBACK TO Create_Agenda_PVT;
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

END Create_Agenda;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Update_Agenda
--
-- PURPOSE
--   This procedure is to update a  Agenda (Track/Session)
--
-- HISTORY
--   02/19/2002        gmadana       created
--
/*****************************************************************************************/

PROCEDURE Update_Agenda
( p_api_version      IN    NUMBER,
  p_init_msg_list    IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit           IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_agenda_rec       IN    agenda_rec_type,
  x_return_status    OUT NOCOPY   VARCHAR2,
  x_msg_count        OUT NOCOPY   NUMBER,
  x_msg_data         OUT NOCOPY   VARCHAR2
) IS

   l_api_name        CONSTANT VARCHAR2(30)  := 'Update_Agenda';
   l_api_version     CONSTANT NUMBER        := 1.0;
   l_return_status   VARCHAR2(1);
   l_agenda_rec      agenda_rec_type;
   l_full_name       CONSTANT VARCHAR2(60)  := G_PACKAGE_NAME || '.' || l_api_name;
   l_act_res_id      NUMBER;
   l_obj_ver_num     NUMBER;
   l_dateDiff        NUMBER := 0;
   l_stdateDiff      NUMBER := 0;
   l_eddateDiff      NUMBER := 0;
   l_oldStdate       DATE := NULL;
   l_oldEddate       DATE :=NULL;


   CURSOR c_resources(l_session_id IN NUMBER) IS
   SELECT activity_resource_id,object_version_number
   FROM ams_act_resources
   WHERE ACT_RESOURCE_USED_BY_ID = p_agenda_rec.agenda_id
   AND   role_cd = 'COORDINATOR'
   AND   resource_id = p_agenda_rec.coordinator_id;

   CURSOR c_olddate  IS
   SELECT start_date_time, end_date_time
   FROM ams_agendas_v
   WHERE agenda_id = p_agenda_rec.agenda_id;


  BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Update_Agenda_PVT;

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

        complete_agenda_rec
        (
           p_agenda_rec,
           l_agenda_rec
        );


       IF (AMS_DEBUG_HIGH_ON) THEN





       AMS_Utility_PVT.debug_message(l_api_name||': check items');


       END IF;
       IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item
       THEN
          Validate_Agenda_Items
          ( p_agenda_rec       => l_agenda_rec,
            p_validation_mode  => JTF_PLSQL_API.g_update,
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

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message(l_full_name ||': check records');

      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record
      THEN
         validate_agenda_record(
            p_agenda_rec    => p_agenda_rec,
            p_complete_rec  => l_agenda_rec,
            x_return_status => l_return_status
         );

         IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;

      /* If we are updating the Coordinator for Session, check whether that
         coordinator(new) is attached as Resources for that Session.If so delete
         him from resources  and then update the Session. For Track, no resources
         are attached, so the following logic is not needed for Tracks.
      */

       IF(l_agenda_rec.agenda_type = 'SESSION')
       THEN
          OPEN  c_resources(l_agenda_rec.agenda_id);
          FETCH c_resources INTO l_act_res_id, l_obj_ver_num;

          IF (AMS_DEBUG_HIGH_ON) THEN



          AMS_Utility_PVT.debug_message('resource_id :' || l_act_res_id);

          END IF;
          IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message('obj_ver_num :' || l_obj_ver_num);
          END IF;

          WHILE c_resources%FOUND LOOP

               AMS_ACTRESOURCE_PVT.DELETE_ACT_RESOURCE
               ( p_api_version       => l_api_version,
                 p_init_msg_list     => FND_API.G_FALSE,
                 p_commit            => FND_API.G_FALSE,
                 p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                 x_return_status     => l_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data,
                 p_act_Resource_id   => l_act_res_id,
                 p_object_version    => l_obj_ver_num
               );

               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF; -- IF l_return_status = FND_API.g_ret_sts_error THEN

               FETCH c_resources INTO l_act_res_id, l_obj_ver_num;

          END LOOP; -- WHILE(c_resources%FOUND)
          CLOSE c_resources;

       END IF; --IF(p_agenda_rec.agenda_type = 'SESSION')

       /* If Session date is changed, then chnage the date of the resources
          associated to them and then update their status to 'UNCONFIRMED'.
          If the Session start time is increased, make start time of resources
          (associated to it) whose start time is  greater than it, equal to it.
          If the Session end time is decreased, make end time of resources
          (associated to it) whose end time is  lesser than it, equal to it.
          If the start time is decreased or end time is increased, it will have no
          effect on the resources.
       */

       OPEN  c_olddate;
       FETCH c_olddate INTO l_oldStdate, l_oldEddate ;
       CLOSE c_olddate;

       IF(l_oldStdate <> p_agenda_rec.start_date_time
          OR l_oldEddate <> p_agenda_rec.end_date_time)
       THEN
            l_dateDiff  := trunc(p_agenda_rec.start_date_time - l_oldStdate);
            l_stdateDiff := l_oldStdate - p_agenda_rec.start_date_time;
            l_eddateDiff := p_agenda_rec.end_date_time - l_oldEddate;

            IF (AMS_DEBUG_HIGH_ON) THEN



            AMS_Utility_PVT.debug_message('l_dateDiff :' || l_DateDiff);

            END IF;
            IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message('l_StdateDiff :' || l_stdateDiff);
            END IF;
            IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message('l_EddateDiff :' || l_eddateDiff);
            END IF;


            IF( ABS(l_dateDiff) > 0)
            THEN

                UPDATE ams_act_resources
                SET system_status_code = 'UNCONFIRMED',
                    object_version_number = object_version_number + 1,
                    user_status_id = ( SELECT user_status_id
                                       FROM AMS_USER_STATUSES_B
                                       WHERE SYSTEM_STATUS_CODE = 'UNCONFIRMED'
                                       AND  SYSTEM_STATUS_TYPE = 'AMS_EVENT_AGENDA_STATUS'
                                       -- added by soagrawa on 25-feb-2003 for bug# 2820297
                                       AND  DEFAULT_FLAG = 'Y'),
                    start_date_time = start_date_time + l_DateDiff,
                    end_date_time   = end_date_time   + l_DateDiff
                WHERE  act_resource_used_by_id = p_agenda_rec.agenda_id
                AND system_status_code <> 'CANCELLED';

           /* ELSIF( (p_agenda_rec.start_date_time > l_oldStdate
                    AND p_agenda_rec.end_date_time < l_oldEddate)
                    OR
                   (p_agenda_rec.start_date_time = l_oldStdate
                    AND p_agenda_rec.end_date_time < l_oldEddate)
                    OR
                   (p_agenda_rec.start_date_time > l_oldStdate
                    AND p_agenda_rec.end_date_time = l_oldEddate)
                 )
            THEN
                UPDATE ams_act_resources
                SET object_version_number = object_version_number + 1,
                    start_date_time = p_agenda_rec.start_date_time,
                    end_date_time   = p_agenda_rec.end_date_time
                WHERE  act_resource_used_by_id = p_agenda_rec.agenda_id
                AND  ( (start_date_time < p_agenda_rec.start_date_time
                       AND    end_date_time > p_agenda_rec.end_date_time)
                       OR
                      (start_date_time = p_agenda_rec.start_date_time
                       AND    end_date_time > p_agenda_rec.end_date_time)
                       OR
                      (end_date_time = p_agenda_rec.end_date_time
                       AND    start_date_time < p_agenda_rec.start_date_time) )
                AND system_status_code <> 'CANCELLED';
            END IF; */

           ELSIF( (p_agenda_rec.start_date_time > l_oldStdate
                    AND p_agenda_rec.end_date_time < l_oldEddate) )
            THEN
                IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_PVT.debug_message('Entered for both dates');
                END IF;

                UPDATE ams_act_resources
                SET object_version_number = object_version_number + 1,
                  --  start_date_time = p_agenda_rec.start_date_time,
                   -- end_date_time   = p_agenda_rec.end_date_time,
                    system_status_code = 'UNCONFIRMED',
                    user_status_id = ( SELECT user_status_id
                                       FROM AMS_USER_STATUSES_B
                                       WHERE SYSTEM_STATUS_CODE = 'UNCONFIRMED'
                                       AND  SYSTEM_STATUS_TYPE = 'AMS_EVENT_AGENDA_STATUS'
                                       -- added by soagrawa on 25-feb-2003 for bug# 2820297
                                       AND  DEFAULT_FLAG = 'Y')
                WHERE  act_resource_used_by_id = p_agenda_rec.agenda_id
                AND    start_date_time < p_agenda_rec.start_date_time
                AND    end_date_time > p_agenda_rec.end_date_time
                AND    system_status_code <> 'CANCELLED';

            ELSIF ( p_agenda_rec.start_date_time = l_oldStdate
                    AND
                    p_agenda_rec.end_date_time < l_oldEddate)
            THEN
                IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_PVT.debug_message('Entered for end date change');
                END IF;

                UPDATE ams_act_resources
                SET object_version_number = object_version_number + 1,
                  --  end_date_time   = p_agenda_rec.end_date_time,
                    system_status_code = 'UNCONFIRMED',
                    user_status_id = ( SELECT user_status_id
                                       FROM AMS_USER_STATUSES_B
                                       WHERE SYSTEM_STATUS_CODE = 'UNCONFIRMED'
                                       AND  SYSTEM_STATUS_TYPE = 'AMS_EVENT_AGENDA_STATUS'
                                       -- added by soagrawa on 25-feb-2003 for bug# 2820297
                                       AND  DEFAULT_FLAG = 'Y')
                WHERE  act_resource_used_by_id = p_agenda_rec.agenda_id
                AND    end_date_time > p_agenda_rec.end_date_time
                AND system_status_code <> 'CANCELLED';

            ELSIF ( p_agenda_rec.end_date_time = l_oldEddate
                    AND p_agenda_rec.start_date_time > l_oldStdate)
            THEN
                IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_PVT.debug_message('Entered for start date change');
                END IF;

                UPDATE ams_act_resources
                SET object_version_number = object_version_number + 1,
                 --   start_date_time   = p_agenda_rec.start_date_time,
                    system_status_code = 'UNCONFIRMED',
                    user_status_id = ( SELECT user_status_id
                                       FROM AMS_USER_STATUSES_B
                                       WHERE SYSTEM_STATUS_CODE = 'UNCONFIRMED'
                                       AND  SYSTEM_STATUS_TYPE = 'AMS_EVENT_AGENDA_STATUS'
                                       -- added by soagrawa on 25-feb-2003 for bug# 2820297
                                       AND  DEFAULT_FLAG = 'Y')
                WHERE  act_resource_used_by_id = p_agenda_rec.agenda_id
                AND    start_date_time < p_agenda_rec.start_date_time
                AND    system_status_code <> 'CANCELLED';

            END IF;

       END IF;


   -------------- Perform the database operation UPDATE----------------------

   UPDATE AMS_AGENDAS_B
   SET
       setup_type_id            = l_agenda_rec.setup_type_id
      ,last_update_date         = sysdate
      ,last_updated_by          = FND_GLOBAL.User_Id
      ,last_update_login        = FND_GLOBAL.Conc_Login_Id
      ,object_version_number    = l_agenda_rec.object_version_number+1
      ,room_id                  = l_agenda_rec.room_id
      ,start_date_time          = l_agenda_rec.start_date_time
      ,end_date_time            = l_agenda_rec.end_date_time
      ,coordinator_id           = l_agenda_rec.coordinator_id
      ,timezone_id              = l_agenda_rec.timezone_id
      ,parent_type              = l_agenda_rec.parent_type
      ,parent_id                = l_agenda_rec.parent_id
      ,attribute_category       = l_agenda_rec.attribute_category
      ,attribute1               = l_agenda_rec.attribute1
      ,attribute2               = l_agenda_rec.attribute2
      ,attribute3               = l_agenda_rec.attribute3
      ,attribute4               = l_agenda_rec.attribute4
      ,attribute5               = l_agenda_rec.attribute5
      ,attribute6               = l_agenda_rec.attribute6
      ,attribute7               = l_agenda_rec.attribute7
      ,attribute8               = l_agenda_rec.attribute8
      ,attribute9               = l_agenda_rec.attribute9
      ,attribute10              = l_agenda_rec.attribute10
      ,attribute11              = l_agenda_rec.attribute11
      ,attribute12              = l_agenda_rec.attribute12
      ,attribute13              = l_agenda_rec.attribute13
      ,attribute14              = l_agenda_rec.attribute14
      ,attribute15              = l_agenda_rec.attribute15
   WHERE agenda_id              = l_agenda_rec.agenda_id
   AND object_version_number    = l_agenda_rec.object_version_number;

   IF (SQL%NOTFOUND)
   THEN

   /*Error, check the msg level and added an error message to the
     API message list
   */
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.Add;
      END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   UPDATE ams_agendas_tl SET
      agenda_name = l_agenda_rec.agenda_name,
      description = l_agenda_rec.description,
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE agenda_id = l_agenda_rec.agenda_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
         RAISE FND_API.g_exc_error;
   END IF;


    /* Roll up the times to Track and then to Event Level */
  /*   Rollup_StTime_EdTime (
         p_agenda_rec    => l_agenda_rec,
         x_return_status => x_return_status
      ); */

      IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
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
           ROLLBACK TO Update_Agenda_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_AND_Get
          ( p_count    =>    x_msg_count,
             p_data     =>    x_msg_data,
             p_encoded  =>    FND_API.G_FALSE
          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO Update_Agenda_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_AND_Get
           ( p_count    =>     x_msg_count,
             p_data     =>     x_msg_data,
             p_encoded  =>     FND_API.G_FALSE
         );

        WHEN OTHERS THEN
           ROLLBACK TO Update_Agenda_PVT;
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

END Update_Agenda;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Delete_Agenda
--
-- PURPOSE
--   This procedure is to delete a Agenda (Track/Session)
--
-- HISTORY
--   02/19/2002        gmadana            created
--
/*****************************************************************************************/

PROCEDURE Delete_Agenda
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2   := FND_API.G_FALSE,
  p_commit           IN     VARCHAR2   := FND_API.G_FALSE,

  p_agenda_id        IN     NUMBER,
  p_object_version   IN     NUMBER,

  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2
) IS

   l_api_name        CONSTANT VARCHAR2(30)  := 'Delete_Agenda';
   l_api_version     CONSTANT NUMBER        := 1.0;
   l_return_status   VARCHAR2(1);
   l_full_name       CONSTANT VARCHAR2(60)  := G_PACKAGE_NAME || '.' || l_api_name;
   l_agenda_rec      agenda_rec_type;
   l_act_res_id      NUMBER;
   l_obj_ver_num     NUMBER;
   l_agenda_id       NUMBER;
   l_count           NUMBER;

   CURSOR c_agenda IS
   SELECT *
   FROM ams_agendas_b
   WHERE agenda_id = p_agenda_id;

   CURSOR c_resources(l_session_id IN NUMBER) IS
   SELECT activity_resource_id,object_version_number
   FROM ams_act_resources
   WHERE act_resource_used_by_id = l_session_id;

   CURSOR c_event_status IS
   SELECT count(event_offer_id)
   FROM  ams_event_offers_vl
   WHERE system_status_code IN ('COMPLETED', 'CANCELLED', 'ON_HOLD','ARCHIVED','CLOSED')
   AND event_offer_id = ( SELECT parent_id
                          FROM   ams_agendas_v
                          WHERE  agenda_id = ( SELECT parent_id
                                               FROM   ams_agendas_v
                                               WHERE  agenda_id = p_agenda_id));

   CURSOR c_sessions IS
   SELECT agenda_id, object_version_number
   FROM   ams_agendas_v
   WHERE  parent_id =  p_agenda_id;

   l_agenda_row   c_agenda%ROWTYPE;


 BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT Delete_Agenda_PVT;

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

    ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   OPEN  c_event_status;
   FETCH c_event_status INTO l_count;
   CLOSE c_event_status;

   IF(l_count > 0)
   THEN
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
      THEN
         Fnd_Message.set_name('AMS', 'AMS_NO_SESSION');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;


   OPEN  c_agenda;
   FETCH c_agenda into l_agenda_row;
   CLOSE c_agenda;

   /* When deleting the Session, delete all the Resources attached to it */
   IF (l_agenda_row.agenda_type = 'SESSION')
   THEN
      OPEN  c_resources(p_agenda_id);
      FETCH c_resources INTO l_act_res_id, l_obj_ver_num ;

      WHILE c_resources%FOUND LOOP

         AMS_ACTRESOURCE_PVT.DELETE_ACT_RESOURCE
         ( p_api_version      => l_api_version,
           p_init_msg_list    => FND_API.G_FALSE,
           p_commit           => FND_API.G_FALSE,
           p_validation_level => FND_API.G_VALID_LEVEL_FULL,
           x_return_status    => l_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           p_act_Resource_id   => l_act_res_id,
           p_object_version   => l_obj_ver_num
         );

         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         FETCH c_resources INTO l_act_res_id, l_obj_ver_num ;

      END LOOP;
      CLOSE c_resources;
    -- To remove TRACK, first remove Sessions and resources attached.
    ELSIF (l_agenda_row.agenda_type = 'TRACK')
    THEN
      OPEN  c_sessions;
      FETCH c_sessions INTO l_agenda_id, l_obj_ver_num ;

      WHILE c_sessions%FOUND LOOP
         /* Deleting the Seesion */
         UPDATE  ams_agendas_b
         SET   active_flag = 'N',
               object_version_number = object_version_number + 1
         WHERE agenda_id = l_agenda_id
         AND   object_version_number = l_obj_ver_num;

         /* Deleting the resources attached to deleted Session */
         OPEN  c_resources(l_agenda_id);
         FETCH c_resources INTO l_act_res_id, l_obj_ver_num ;

         WHILE c_resources%FOUND LOOP

            AMS_ACTRESOURCE_PVT.DELETE_ACT_RESOURCE
            ( p_api_version       => l_api_version,
              p_init_msg_list     => FND_API.G_FALSE,
              p_commit            => FND_API.G_FALSE,
              p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
              x_return_status     => l_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_act_Resource_id   => l_act_res_id,
              p_object_version    => l_obj_ver_num
            );

            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            FETCH c_resources INTO l_act_res_id, l_obj_ver_num ;

         END LOOP; --WHILE c_resources%FOUND LOOP
         CLOSE c_resources;

         FETCH c_sessions INTO l_agenda_id, l_obj_ver_num ;

      END LOOP; -- WHILE c_sessions%FOUND LOOP
      CLOSE c_sessions;

    END IF;

   /* Deleting the Object (Track/Session) passed in */
   UPDATE ams_agendas_b
   SET   active_flag = 'N',
         object_version_number = object_version_number + 1
   WHERE agenda_id = p_agenda_id
   AND   object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;


   ---Roll up the times to Track and then to Event Level---
   ---Creating the l_agenda_rec------------
   l_agenda_rec.agenda_id := p_agenda_id;
   l_agenda_rec.parent_id := l_agenda_row.parent_id;

 /* Rollup_StTime_EdTime (
      p_agenda_rec    => l_agenda_rec,
      x_return_status => x_return_status
   ); */

   IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
      RAISE Fnd_Api.g_exc_error;
   END IF;

   -------------------- finish --------------------------

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
         ROLLBACK TO Delete_Agenda_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;

         FND_MSG_PUB.Count_AND_Get
         ( p_count   =>      x_msg_count,
           p_data    =>      x_msg_data,
           p_encoded =>      FND_API.G_FALSE
         );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Delete_Agenda_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         FND_MSG_PUB.Count_AND_Get
         ( p_count   =>      x_msg_count,
           p_data    =>      x_msg_data,
           p_encoded =>      FND_API.G_FALSE
          );

      WHEN OTHERS THEN
          ROLLBACK TO Delete_Agenda_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
          END IF;

         FND_MSG_PUB.Count_AND_Get
         ( p_count   =>      x_msg_count,
           p_data    =>      x_msg_data,
           p_encoded =>      FND_API.G_FALSE
         );

END Delete_Agenda;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Lock_Agenda
--
-- PURPOSE
--   This procedure is to lock a agenda record
--
-- HISTORY
--   02/19/2002       gmadana            created
--
/*****************************************************************************************/

PROCEDURE Lock_Agenda
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2    := FND_API.G_FALSE,
  p_agenda_id           IN     NUMBER,
  p_object_version      IN     NUMBER,
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2
) IS

   l_api_name          CONSTANT VARCHAR2(30)  := 'Lock_Agenda';
   l_api_version       CONSTANT NUMBER        := 1.0;
   l_return_status     VARCHAR2(1);
   l_agenda_id         NUMBER;


   CURSOR c_agenda IS
   SELECT agenda_id
   FROM AMS_AGENDAS_V
   WHERE agenda_id = p_agenda_id
   AND object_version_number = p_object_version
   FOR UPDATE of agenda_id NOWAIT;

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

   -- Perform the database operation
   OPEN c_agenda;
   FETCH c_agenda INTO l_agenda_id;
   IF (c_agenda%NOTFOUND) THEN
     CLOSE c_agenda;

  /* Error, check the msg level and added an error message to the
     API message list
   */
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_agenda;

    -- Standard call to get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_AND_Get
    ( p_count     =>      x_msg_count,
      p_data      =>      x_msg_data,
      p_encoded   =>      FND_API.G_FALSE
    );
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_AND_Get
         ( p_count   =>      x_msg_count,
           p_data    =>      x_msg_data,
           p_encoded =>      FND_API.G_FALSE
         );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_AND_Get
         ( p_count   =>      x_msg_count,
           p_data    =>      x_msg_data,
           p_encoded =>      FND_API.G_FALSE
         );

    /*  WHEN AMS_Utility_PVT.agenda_locked THEN
          x_return_status := FND_API.g_ret_sts_error;
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
             FND_MSG_PUB.add;
          END IF; */

          FND_MSG_PUB.Count_AND_Get
          ( p_count     =>      x_msg_count,
            p_data      =>      x_msg_data,
            p_encoded   =>      FND_API.G_FALSE
          );

        WHEN OTHERS THEN
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

END Lock_Agenda;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Agenda
--
-- PURPOSE
--   This procedure is to validate an agenda record
--
-- HISTORY
--   02/19/2002       gmadana            created
--
/*****************************************************************************************/

PROCEDURE Validate_Agenda
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_agenda_rec       IN     agenda_rec_type,
  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2
) IS

  l_api_name      CONSTANT VARCHAR2(30)    := 'Validate_Agenda';
  l_api_version   CONSTANT NUMBER          := 1.0;
  l_full_name     CONSTANT VARCHAR2(60)    := G_PACKAGE_NAME || '.' || l_api_name;
  l_return_status VARCHAR2(1);
  l_agenda_rec    agenda_rec_type          := p_agenda_rec;

       -- l_default_act_resource_rec    act_Resource_rec_type;
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
      Validate_Agenda_Items
      ( p_agenda_rec       => l_agenda_rec,
        p_validation_mode  => JTF_PLSQL_API.g_create,
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

   -- Perform cross attribute validation and missing attribute checks. Record
   -- level validation.
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check record level');
   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record
   THEN
      Validate_Agenda_Record(
      p_agenda_rec          => l_agenda_rec,
      x_return_status       => l_return_status
    );

    -- If any errors happen abort API.
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
         ( p_count    =>      x_msg_count,
           p_data     =>      x_msg_data,
           p_encoded  =>      FND_API.G_FALSE
         );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_AND_Get
          ( p_count    =>      x_msg_count,
            p_data     =>      x_msg_data,
            p_encoded  =>      FND_API.G_FALSE
          );
        WHEN OTHERS THEN
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

END Validate_Agenda;

/*****************************************************************************************/
-- PROCEDURE
--    check_agenda_req_items
--
-- HISTORY
--    02/20/2002  gmadana  Created.
/*****************************************************************************************/
PROCEDURE check_agenda_req_items(
   p_agenda_rec     IN  agenda_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

    x_return_status := FND_API.g_ret_sts_success;

    ------------------------ application_id --------------------------
   IF (p_agenda_rec.application_id IS NULL OR p_agenda_rec.application_id = FND_API.g_miss_num) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_NO_APPLICATION_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
  END IF;
   ------------------------ parent_id--------------------------
  IF (p_agenda_rec.parent_id IS NULL OR p_agenda_rec.parent_id = FND_API.g_miss_num) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         IF (p_agenda_rec.agenda_type = 'TRACK')
         THEN
             FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_PARENT_OFFER_ID');
        -- ELSIF(p_agenda_rec.agenda_type = 'SESSION')
          --   FND_MESSAGE.set_name('AMS', 'AMS_NO_TRACK_ID');
         END IF;
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   ------------------------ parent_type--------------------------
   IF (p_agenda_rec.parent_type IS NULL OR p_agenda_rec.parent_type = FND_API.g_miss_char) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         IF (p_agenda_rec.agenda_type = 'TRACK')
         THEN
             FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_PARENT_OFFER_TYPE');
         ELSIF(p_agenda_rec.agenda_type = 'SESSION')THEN
             FND_MESSAGE.set_name('AMS', 'AMS_NO_TRACK_TYPE');
         END IF;
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

  ------------------------ agenda_type--------------------------
   IF (p_agenda_rec.agenda_type IS NULL OR p_agenda_rec.agenda_type = FND_API.g_miss_char) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_NO_AGENDA_TYPE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;


END check_agenda_req_items;

/*****************************************************************************************/
-- PROCEDURE
--    check_agenda_uk_items
--
-- HISTORY
--    02/20/2002  gmadana  Created.
/*****************************************************************************************/
PROCEDURE check_agenda_uk_items(
   p_agenda_rec      IN  agenda_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
   l_dummy NUMBER;

   cursor c_track_name IS
   SELECT 1 FROM DUAL
   WHERE EXISTS (SELECT 1 from ams_agendas_v
                 WHERE agenda_name = p_agenda_rec.agenda_name
                 AND  parent_id = p_agenda_rec.parent_id);


BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- For create_agenda, when agenda_id is passed in, we need to
   -- check if this agenda_id is unique.

   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_agenda_rec.agenda_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
            'ams_agendas_v',
            'agenda_id = ' || p_agenda_rec.agenda_id
            ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

    /* IF the agenda_type = 'TRACK' then the Track Name + Parent Id has to
       be unique. If it is SESSION then no validation is necessary.
    */

      IF(p_agenda_rec.agenda_type = 'TRACK')
      THEN
         OPEN c_track_name;
         fetch c_track_name into l_dummy;
         close c_track_name;
         IF l_dummy = 1 THEN
            IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name ('AMS', 'AMS_DUP_NAME');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

END check_agenda_uk_items;

/*****************************************************************************************/
-- PROCEDURE
--    check_agenda_fk_items
--
-- HISTORY
--    02/20/2002  gmadana  Created.
/*****************************************************************************************/
PROCEDURE check_agenda_fk_items(
   p_agenda_rec        IN  agenda_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                NUMBER;
   l_additional_where_clause     VARCHAR2(4000);
   l_where_clause VARCHAR2(80) := null;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   --------------------- application_id ------------------------
  IF p_agenda_rec.application_id <> FND_API.g_miss_num AND
     p_agenda_rec.application_id is NOT NULL
  THEN
     IF AMS_Utility_PVT.check_fk_exists(
            'fnd_application',
            'application_id',
            p_agenda_rec.application_id
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
  END IF;


   ----------------------- parent_id/parent_type ------------------------
   IF (p_agenda_rec.parent_type = 'EVEO' OR p_agenda_rec.parent_type = 'EONE')
   THEN
      IF p_agenda_rec.parent_id <> FND_API.g_miss_num
        AND p_agenda_rec.parent_id IS NOT NULL  THEN
            IF AMS_Utility_PVT.check_fk_exists(
               'ams_event_offers_vl',
               'event_offer_id',
               p_agenda_rec.parent_id
            ) = FND_API.g_false
            THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_PARENT_OFFER');
                  FND_MSG_PUB.add;
               END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;
         END IF;
    ELSIF p_agenda_rec.parent_type = 'TRACK'
    THEN
      IF p_agenda_rec.parent_id <> FND_API.g_miss_num
        AND p_agenda_rec.parent_id IS NOT NULL  THEN
            IF AMS_Utility_PVT.check_fk_exists(
               'ams_agendas_v',
               'agenda_id',
               p_agenda_rec.parent_id
            ) = FND_API.g_false
            THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_PARENT_OFFER');
                  FND_MSG_PUB.add;
               END IF;
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;
         END IF;
     END IF;


----------------------- TIMEZONE_ID ------------------------
   IF p_agenda_rec.timezone_id <> FND_API.g_miss_num
      AND p_agenda_rec.timezone_id IS NOT NULL  THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_timezones_b',
            'upgrade_tz_id',
            p_agenda_rec.timezone_id
        ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_TIMEZONE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

----------------------- room_id ------------------------
   IF p_agenda_rec.room_id <> FND_API.g_miss_num
      AND p_agenda_rec.room_id IS NOT NULL  THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_venues_vl',
            'venue_id',
            p_agenda_rec.room_id
        ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_VENUE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------- COORDINATOR_ID -------------------------
   IF p_agenda_rec.COORDINATOR_ID <> FND_API.g_miss_num
   THEN
      l_table_name := 'HZ_PARTIES';
      l_pk_name    := 'PARTY_ID';
      l_pk_value := p_agenda_rec.COORDINATOR_ID;
      IF AMS_Utility_PVT.Check_FK_Exists (
         p_table_name       => l_table_name
        ,p_pk_name          => l_pk_name
        ,p_pk_value         => l_pk_value
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


END check_agenda_fk_items;

/*****************************************************************************************/
-- PROCEDURE
--    check_agenda_lookup_items
--
-- HISTORY
--    02/20/2002  gmadana  Created.
/*****************************************************************************************/
PROCEDURE check_agenda_lookup_items(
   p_agenda_rec        IN  agenda_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- agenda_type ------------------------
   /*IF p_agenda_rec.agenda_type <> FND_API.g_miss_char
      AND p_agenda_rec.agenda_type IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_SYS_ARC_QUALIFIER',
            p_lookup_code => p_agenda_rec.agenda_type
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;*/


END check_agenda_lookup_items;

/*****************************************************************************************/
-- PROCEDURE
--    check_agenda_flag_items
--
-- HISTORY
--    02/20/2002  gmadana  Created
/*****************************************************************************************/
PROCEDURE check_agenda_flag_items(
   p_agenda_rec        IN  agenda_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   ----------------------- active_flag ------------------------
   IF p_agenda_rec.active_flag <> FND_API.g_miss_char
      AND p_agenda_rec.active_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_agenda_rec.active_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_ACTIVE_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

    ----------------------- DEFAULT_TRACK_FLAG ------------------------
   IF p_agenda_rec.default_track_flag <> FND_API.g_miss_char
      AND p_agenda_rec.default_track_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_agenda_rec.default_track_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_TRACK_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


END check_agenda_flag_items;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Agenda_Items
--
-- PURPOSE
--   This procedure is to validate Agenda items
--
/*****************************************************************************************/

PROCEDURE Validate_Agenda_Items
( p_agenda_rec       IN  agenda_rec_type,
  p_validation_mode  IN  VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status    OUT NOCOPY VARCHAR2
) IS

   l_table_name   VARCHAR2(30);
   l_pk_name      VARCHAR2(30);
   l_pk_value     VARCHAR2(30);
   l_where_clause VARCHAR2(2000);

   l_event_id        NUMBER;
   l_track_id        NUMBER;
   l_count           NUMBER;
   l_event_stdate    DATE;
   l_event_eddate    DATE;
   l_parent_id       NUMBER;
   l_start_date      DATE;
   l_end_date        DATE;

   l_strdate        VARCHAR2(30);
   l_strdate1       VARCHAR2(30);


   CURSOR c_get_event_dates(l_offer_id IN NUMBER) IS
   SELECT event_start_date_time, event_end_date_time
   FROM  ams_event_offers_all_b
   WHERE event_offer_id = l_offer_id;

   CURSOR c_get_event_id(id_in IN NUMBER) IS
   SELECT parent_id
   FROM  ams_agendas_v
   WHERE agenda_id = id_in;

   CURSOR c_get_resource_dates(id_in IN NUMBER) IS
   SELECT min(start_date_time), max(end_date_time)
   FROM  ams_act_resources
   WHERE act_resource_used_by_id = id_in
   and  arc_act_resource_used_by = 'SESSION'
   and system_status_code = 'CONFIRMED';

   CURSOR c_parent_status IS
   SELECT count(event_offer_id)
   FROM  ams_event_offers_all_b
   WHERE system_status_code IN ('COMPLETED', 'CANCELLED', 'ON_HOLD','ARCHIVED','CLOSED')
   AND event_offer_id = p_agenda_rec.parent_id;

   CURSOR c_event_status IS
   SELECT count(event_offer_id)
   FROM  ams_event_offers_all_b
   WHERE system_status_code IN ('COMPLETED', 'CANCELLED', 'ON_HOLD','ARCHIVED','CLOSED')
   AND event_offer_id = ( SELECT parent_id
                          FROM   ams_agendas_b
                          WHERE  agenda_id = p_agenda_rec.parent_id);




BEGIN

   --  Initialize API/Procedure return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

      -------------------------- Update Mode ----------------------------
   -- check if the p_agenda_rec has any columns that should not be updated at this
   -- stage as per the business logic.
   -- for example, changes to source_code should not be allowed at any update.
   -- Also when the event is in active stage, changes to marketing message and
   -- budget related columns should not be allowed.

  /* IF (AMS_DEBUG_HIGH_ON) THEN  AMS_UTILITY_PVT.debug_message('before ok_items'); END IF;
   IF p_validation_mode = JTF_PLSQL_API.g_update THEN
        check_evo_update_ok_items(
           p_agenda_rec        => p_agenda_rec,
           x_return_status  => x_return_status
        );

       IF x_return_status <> FND_API.g_ret_sts_success THEN
          RETURN;
       END IF;
    END IF; */

 /*  IF p_validation_mode = JTF_PLSQL_API.g_update THEN
       open c_get_resource_dates(p_agenda_rec.agenda_id);
       fetch c_get_resource_dates into l_start_date, l_end_date;
       close c_get_resource_dates;
       if (p_agenda_rec.START_DATE_TIME >  l_start_date
           OR p_agenda_rec.END_DATE_TIME < l_end_date)
       THEN
           IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
           THEN
             Fnd_Message.set_name('AMS', 'AMS_EVT_RES_DATE_NOT_FIT_IN');
             Fnd_Msg_Pub.ADD;
           END IF;
           RAISE FND_API.g_exc_error;
        END IF;
    END IF;  */


   --------------------------------------Create mode--------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Checking uk_items');
   END IF;
   check_agenda_uk_items(
      p_agenda_rec      => p_agenda_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   -------------------------- Create or Update Mode ----------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Checking req_items');
   END IF;
   check_agenda_req_items(
      p_agenda_rec     => p_agenda_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_UTILITY_PVT.debug_message('Checking fk_items');

  END IF;
  check_agenda_fk_items(
      p_agenda_rec     => p_agenda_rec,
      x_return_status  => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Checking lookup_items');

   END IF;
   check_agenda_lookup_items(
      p_agenda_rec      => p_agenda_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('Checking flag_items');

   END IF;
   check_agenda_flag_items(
      p_agenda_rec      => p_agenda_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   /* If the Event Schedule is CANCELLED/COMPLETED/ARCHIVED /ON_HOLD/CLOSED
      donot create any SESSIONS
   */

   IF (p_agenda_rec.parent_type = 'EVEO'
       OR
       p_agenda_rec.parent_type = 'EONE'
      )
   THEN
       OPEN  c_parent_status;
       FETCH c_parent_status INTO l_count;
       CLOSE c_parent_status;

       IF(l_count > 0)
       THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
             IF p_agenda_rec.agenda_type = 'SESSION'
             THEN
                Fnd_Message.set_name('AMS', 'AMS_NO_SESSION');
                Fnd_Msg_Pub.ADD;
             ELSIF p_agenda_rec.agenda_type = 'TRACK'
             THEN
                Fnd_Message.set_name('AMS', 'AMS_NO_TRACK');
                Fnd_Msg_Pub.ADD;
             END IF;
          END IF;
          RAISE FND_API.g_exc_error;
       END IF;
   ELSIF(p_agenda_rec.parent_type = 'TRACK')
   THEN
       OPEN  c_event_status;
       FETCH c_event_status INTO l_count;
       CLOSE c_event_status;

       IF(l_count > 0)
       THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
             Fnd_Message.set_name('AMS', 'AMS_NO_SESSION');
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE FND_API.g_exc_error;
       END IF;
   END IF;


   /* End Date time has to be greater than Start date time */

   IF(p_agenda_rec.start_date_time > p_agenda_rec.end_date_time)
   THEN
       --  IF (AMS_DEBUG_HIGH_ON) THEN    Ams_Utility_Pvt.debug_message('The End time is lesser than Start time');  END IF;
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
         THEN
             Fnd_Message.set_name('AMS', 'AMS_EDTIME_LS_STTIME');
             Fnd_Msg_Pub.ADD;
         END IF;
         RAISE FND_API.g_exc_error;
   END IF; -- (p_agenda_rec.start_date_time > p_agenda_rec.end_date_time)


  /* If we are creating Session, check whether the date of Session is within
     the Date Range of Event Schedule for which it is created.
  */
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Checking the Date range');
   END IF;
   IF (p_agenda_rec.agenda_type = 'SESSION')
   THEN

      IF(p_agenda_rec.parent_type = 'TRACK')
      THEN
         OPEN c_get_event_id(p_agenda_rec.parent_id);
         FETCH c_get_event_id into l_event_id;
         CLOSE c_get_event_id;

         OPEN  c_get_event_dates(l_event_id);
         FETCH c_get_event_dates into l_event_stdate, l_event_eddate;
         CLOSE c_get_event_dates;
     ELSE
         OPEN  c_get_event_dates(p_agenda_rec.parent_id);
         FETCH c_get_event_dates into l_event_stdate, l_event_eddate;
         CLOSE c_get_event_dates;
     END IF;

    /* If start time and end time of Session are 12:00 AM, we used to consider
       the duration of session as 24 Hr. This is no longer valid. So following
       code is commented.

     IF (l_event_stdate is not null)
     THEN
         l_strdate := to_char(l_event_stdate, 'dd-MM-rrrr');
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('Date string '|| l_strdate);
         END IF;
         l_strdate1 := l_strdate ||' '|| '00:00';
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('event start date '|| l_strdate1);
         END IF;
         l_event_stdate := to_date (l_strdate1, 'dd-mm-yyyy hh24:mi');
      END IF;

      IF (l_event_eddate is not null)
      THEN
         l_strdate := to_char(l_event_eddate, 'dd-MM-rrrr');
         l_strdate1 := l_strdate ||' '|| '23:59';
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('event end date '|| l_strdate1);
         END IF;
         l_event_eddate := to_date (l_strdate1, 'dd-mm-yyyy hh24:mi');
      END IF;

     IF(to_char(l_event_eddate,'HH24:MI') = '00:00')
      THEN
         l_strdate := to_char(l_event_eddate, 'DD-MM-YYYY');
         l_strdate1 := l_strdate ||' '|| '23:59';
         l_event_eddate := to_date (l_strdate1, 'DD-MM-YYYY HH24:MI');
      END IF;
   */


   /* IF (AMS_DEBUG_HIGH_ON) THEN  Ams_Utility_Pvt.debug_message('Session st date' ||p_agenda_rec.start_date_time ); END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Session ed date' ||p_agenda_rec.end_date_time );
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Session st date' ||to_date(to_char(p_agenda_rec.start_date_time,'DD-MM-YYYY'),'DD-MM-YYYY') );
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Session ed date' ||to_date(to_char(p_agenda_rec.end_date_time,'DD-MM-YYYY'),'DD-MM-YYYY'));
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Event st date' ||to_date(to_char(l_event_stdate,'DD-MM-YYYY'),'DD-MM-YYYY'));
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Event ed date' ||to_date(to_char(l_event_eddate,'DD-MM-YYYY'),'DD-MM-YYYY'));
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Event st time' || to_char(l_event_stdate, 'HH24:MI'));
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      Ams_Utility_Pvt.debug_message('Event Ed time' || to_char(l_event_eddate, 'HH24:MI'));
      END IF;
   */

      /* The Session date has to be with in the date range of event. If the
         Session date is equal to event start date then session start time
         cannot be lesser than event start time. If the Session date is equal
         to event end date, then Session end time cannot be greater than event
         end time.
       */

      IF( to_date(to_char(p_agenda_rec.start_date_time,'DD-MM-YYYY'),'DD-MM-YYYY' ) > to_date(to_char(l_event_eddate,'DD-MM-YYYY'),'DD-MM-YYYY') OR
          to_date(to_char(p_agenda_rec.start_date_time,'DD-MM-YYYY'),'DD-MM-YYYY') < to_date(to_char(l_event_stdate,'DD-MM-YYYY'),'DD-MM-YYYY'))
      THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

         Ams_Utility_Pvt.debug_message('Came to check with event dates');
         END IF;
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
         THEN
             Fnd_Message.set_name('AMS', 'AMS_SESSION_LS_EVENT_DATE');
             Fnd_Msg_Pub.ADD;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF; -- end of start_date_time < l_event_start_date_time

      IF(to_date(to_char(p_agenda_rec.start_date_time,'DD-MM-YYYY'),'DD-MM-YYYY') = to_date(to_char(l_event_stdate,'DD-MM-YYYY'),'DD-MM-YYYY'))
      THEN
          IF( p_agenda_rec.start_date_time  < l_event_stdate )
          THEN
              IF (AMS_DEBUG_HIGH_ON) THEN

              Ams_Utility_Pvt.debug_message('Came to check with event start time');
              END IF;
              IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
              THEN
                 Fnd_Message.set_name('AMS', 'AMS_SESSION_LS_EVENT_TIME');
                 Fnd_Msg_Pub.ADD;
              END IF;
              RAISE FND_API.g_exc_error;
          END IF; --IF( to_date(to_char(p_agenda_rec.start_date_time,'HH24:MI'))
     END IF;

     IF(to_date(to_char(p_agenda_rec.end_date_time,'DD-MM-YYYY'),'DD-MM-YYYY') = to_date(to_char(l_event_eddate,'DD-MM-YYYY'),'DD-MM-YYYY'))
     THEN
          IF( p_agenda_rec.end_date_time > l_event_eddate )
          THEN
              IF (AMS_DEBUG_HIGH_ON) THEN

              Ams_Utility_Pvt.debug_message('Came to check with event end time');
              END IF;
              IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR)
              THEN
                 Fnd_Message.set_name('AMS', 'AMS_SESSION_GT_EVENT_TIME');
                 Fnd_Msg_Pub.ADD;
              END IF;
              RAISE FND_API.g_exc_error;
          END IF; --IF( to_date(to_char(p_agenda_rec.start_date_time,'HH24:MI'))
    END IF;

    END IF; -- end of if SESSION

END Validate_Agenda_Items;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Agenda_Record
--
-- PURPOSE
--   This procedure is to validate agenda record
--
-- NOTES
--
/*****************************************************************************************/

PROCEDURE Validate_Agenda_Record(
  p_agenda_rec       IN  agenda_rec_type,
  p_complete_rec     IN  agenda_rec_type := NULL,
  x_return_status   OUT NOCOPY  VARCHAR2
) IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'Validate_Agenda_Record';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_return_status VARCHAR2(1);

  BEGIN
    -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (
                    l_api_version,
                    l_api_version,
                    l_api_name,
                    G_PACKAGE_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

END Validate_Agenda_Record;

/*****************************************************************************************/
-- PROCEDURE
--    init_agenda_rec
--
-- HISTORY
--    02/20/2002  gmadana  Create.
/*****************************************************************************************/
PROCEDURE init_agenda_rec(
  p_agenda_rec   IN   agenda_rec_type,
  x_agenda_rec   OUT NOCOPY  agenda_rec_type
)
IS
BEGIN

   x_agenda_rec.agenda_id := FND_API.g_miss_num;
   x_agenda_rec.last_update_date := FND_API.g_miss_date;
   x_agenda_rec.last_updated_by := FND_API.g_miss_num;
   x_agenda_rec.creation_date := FND_API.g_miss_date;
   x_agenda_rec.created_by := FND_API.g_miss_num;
   x_agenda_rec.last_update_login := FND_API.g_miss_num;
   x_agenda_rec.object_version_number := FND_API.g_miss_num;
   x_agenda_rec.application_id := FND_API.g_miss_num;
   x_agenda_rec.active_flag := FND_API.g_miss_char;
   x_agenda_rec.default_track_flag := FND_API.g_miss_char;
   x_agenda_rec.coordinator_id := FND_API.g_miss_num;
   x_agenda_rec.timezone_id   := FND_API.g_miss_num;
   x_agenda_rec.attribute_category := FND_API.g_miss_char;
   x_agenda_rec.attribute1 := FND_API.g_miss_char;
   x_agenda_rec.attribute2 := FND_API.g_miss_char;
   x_agenda_rec.attribute3 := FND_API.g_miss_char;
   x_agenda_rec.attribute4 := FND_API.g_miss_char;
   x_agenda_rec.attribute5 := FND_API.g_miss_char;
   x_agenda_rec.attribute6 := FND_API.g_miss_char;
   x_agenda_rec.attribute7 := FND_API.g_miss_char;
   x_agenda_rec.attribute8 := FND_API.g_miss_char;
   x_agenda_rec.attribute9 := FND_API.g_miss_char;
   x_agenda_rec.attribute10 := FND_API.g_miss_char;
   x_agenda_rec.attribute11 := FND_API.g_miss_char;
   x_agenda_rec.attribute12 := FND_API.g_miss_char;
   x_agenda_rec.attribute13 := FND_API.g_miss_char;
   x_agenda_rec.attribute14 := FND_API.g_miss_char;
   x_agenda_rec.attribute15 := FND_API.g_miss_char;
   x_agenda_rec.agenda_name := FND_API.g_miss_char;

   x_agenda_rec.description       := FND_API.g_miss_char;
   x_agenda_rec.START_DATE_TIME   := FND_API.g_miss_date;
   x_agenda_rec.END_DATE_TIME     := FND_API.g_miss_date;
   x_agenda_rec.parent_id         := FND_API.g_miss_num;
   x_agenda_rec.parent_type       := FND_API.g_miss_char;
   x_agenda_rec.agenda_type       := FND_API.g_miss_char;
   x_agenda_rec.ROOM_ID           := FND_API.g_miss_num;

END init_agenda_rec;



/*****************************************************************************************/
-- PROCEDURE
--    complete_agenda_rec
--
-- HISTORY
--    02/20/2002  gmadana  Created.
/*****************************************************************************************/

PROCEDURE complete_agenda_rec(
   p_agenda_rec  IN    agenda_rec_type,
   x_agenda_rec  OUT NOCOPY   agenda_rec_type
) IS

-- Replaced   ams_agendas_v   to AMS_AGENDAS_B  Sikalyan Perfomance BugFix

   CURSOR c_agenda IS
   SELECT *
   FROM AMS_AGENDAS_B
   WHERE agenda_id = p_agenda_rec.agenda_id;

   l_agenda_rec c_agenda%ROWTYPE;

BEGIN
   x_agenda_rec  :=  p_agenda_rec;

   OPEN c_agenda;
   FETCH c_agenda INTO l_agenda_rec;
   IF c_agenda%NOTFOUND THEN
     CLOSE c_agenda;

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;

   CLOSE c_agenda;


   IF p_agenda_rec.ACTIVE_FLAG = FND_API.g_miss_char THEN
      x_agenda_rec.ACTIVE_FLAG := l_agenda_rec.ACTIVE_FLAG;
   END IF;

   IF p_agenda_rec.DEFAULT_TRACK_FLAG = FND_API.g_miss_char THEN
      x_agenda_rec.DEFAULT_TRACK_FLAG := l_agenda_rec.DEFAULT_TRACK_FLAG;
   END IF;

   IF p_agenda_rec.room_id = FND_API.g_miss_num THEN
      x_agenda_rec.room_id := l_agenda_rec.room_id;
   END IF;

   IF p_agenda_rec.SETUP_TYPE_ID = FND_API.g_miss_num THEN
      x_agenda_rec.SETUP_TYPE_ID := l_agenda_rec.SETUP_TYPE_ID;
   END IF;


   IF p_agenda_rec.TIMEZONE_ID = FND_API.g_miss_num THEN
      x_agenda_rec.TIMEZONE_ID := l_agenda_rec.TIMEZONE_ID;
   END IF;

   IF p_agenda_rec.PARENT_ID = FND_API.g_miss_num THEN
      x_agenda_rec.PARENT_ID := l_agenda_rec.PARENT_ID;
   END IF;

   IF p_agenda_rec.PARENT_TYPE = FND_API.g_miss_char THEN
      x_agenda_rec.PARENT_TYPE := l_agenda_rec.PARENT_TYPE;
   END IF;

   IF p_agenda_rec.agenda_type = FND_API.g_miss_char THEN
      x_agenda_rec.agenda_type := l_agenda_rec.agenda_type;
   END IF;

   IF p_agenda_rec.application_id = FND_API.g_miss_num THEN
      x_agenda_rec.application_id := l_agenda_rec.application_id;
   END IF;

   IF p_agenda_rec.created_by = FND_API.g_miss_num THEN
      x_agenda_rec.created_by := l_agenda_rec.created_by;
   END IF;

   IF p_agenda_rec.last_updated_by = FND_API.g_miss_num THEN
      x_agenda_rec.last_updated_by := l_agenda_rec.last_updated_by;
   END IF;

   IF p_agenda_rec.START_DATE_TIME = FND_API.g_miss_date THEN
      x_agenda_rec.START_DATE_TIME := l_agenda_rec.START_DATE_TIME;
   END IF;

   IF p_agenda_rec.END_DATE_TIME = FND_API.g_miss_date THEN
      x_agenda_rec.END_DATE_TIME := l_agenda_rec.END_DATE_TIME;
   END IF;



   IF p_agenda_rec.ATTRIBUTE_CATEGORY = FND_API.g_miss_char THEN
      x_agenda_rec.ATTRIBUTE_CATEGORY := l_agenda_rec.ATTRIBUTE_CATEGORY;
   END IF;

   IF p_agenda_rec.ATTRIBUTE1 = FND_API.g_miss_char THEN
      x_agenda_rec.ATTRIBUTE1 := l_agenda_rec.ATTRIBUTE1;
   END IF;

   IF p_agenda_rec.ATTRIBUTE2 = FND_API.g_miss_char THEN
      x_agenda_rec.ATTRIBUTE2 := l_agenda_rec.ATTRIBUTE2;
   END IF;

   IF p_agenda_rec.ATTRIBUTE3 = FND_API.g_miss_char THEN
      x_agenda_rec.ATTRIBUTE3 := l_agenda_rec.ATTRIBUTE3;
   END IF;

   IF p_agenda_rec.ATTRIBUTE4 = FND_API.g_miss_char THEN
      x_agenda_rec.ATTRIBUTE4 := l_agenda_rec.ATTRIBUTE4;
   END IF;

   IF p_agenda_rec.ATTRIBUTE5 = FND_API.g_miss_char THEN
      x_agenda_rec.ATTRIBUTE5 := l_agenda_rec.ATTRIBUTE5;
   END IF;

   IF p_agenda_rec.ATTRIBUTE6 = FND_API.g_miss_char THEN
      x_agenda_rec.ATTRIBUTE6 := l_agenda_rec.ATTRIBUTE6;
     END IF;
   IF p_agenda_rec.ATTRIBUTE7 = FND_API.g_miss_char THEN
      x_agenda_rec.ATTRIBUTE7 := l_agenda_rec.ATTRIBUTE7;
     END IF;
   IF p_agenda_rec.ATTRIBUTE8 = FND_API.g_miss_char THEN
      x_agenda_rec.ATTRIBUTE8 := l_agenda_rec.ATTRIBUTE8;
   END IF;

  IF p_agenda_rec.ATTRIBUTE9 = FND_API.g_miss_char THEN
     x_agenda_rec.ATTRIBUTE9 := l_agenda_rec.ATTRIBUTE9;
  END IF;

  IF p_agenda_rec.ATTRIBUTE10 = FND_API.g_miss_char THEN
     x_agenda_rec.ATTRIBUTE10 := l_agenda_rec.ATTRIBUTE10;
  END IF;

  IF p_agenda_rec.ATTRIBUTE11 = FND_API.g_miss_char THEN
     x_agenda_rec.ATTRIBUTE11 := l_agenda_rec.ATTRIBUTE11;
  END IF;

  IF p_agenda_rec.ATTRIBUTE11 = FND_API.g_miss_char THEN
     x_agenda_rec.ATTRIBUTE11 := l_agenda_rec.ATTRIBUTE11;
  END IF;

  IF p_agenda_rec.ATTRIBUTE12 = FND_API.g_miss_char THEN
     x_agenda_rec.ATTRIBUTE12 := l_agenda_rec.ATTRIBUTE12;
  END IF;

  IF p_agenda_rec.ATTRIBUTE13 = FND_API.g_miss_char THEN
    x_agenda_rec.ATTRIBUTE13 := l_agenda_rec.ATTRIBUTE13;
  END IF;

  IF p_agenda_rec.ATTRIBUTE14 = FND_API.g_miss_char THEN
     x_agenda_rec.ATTRIBUTE14 := l_agenda_rec.ATTRIBUTE14;
  END IF;

  IF p_agenda_rec.ATTRIBUTE15 = FND_API.g_miss_char THEN
     x_agenda_rec.ATTRIBUTE15 := l_agenda_rec.ATTRIBUTE15;
  END IF;

END complete_agenda_rec;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Rollup_StTime_EdTime
--
-- PURPOSE
--   This procedure rolls up the start time and end time of Session to Track level
--   and then to Event level.
--
-- NOTES
--
/*****************************************************************************************/

PROCEDURE Rollup_StTime_EdTime (
  p_agenda_rec      IN   agenda_rec_type,
  x_return_status   OUT NOCOPY  VARCHAR2
) IS

l_parent_id       NUMBER;
l_min_time        DATE;
l_max_time        DATE;

cursor c_parent_id(id_in IN NUMBER) is
   select parent_id
   from ams_agendas_v
   where agenda_id = id_in;

cursor c_min_max_times(id_in IN NUMBER) is
   SELECT MIN(start_date_time), MAX(end_date_time)
   from ams_agendas_v
   where parent_id = id_in
   and   active_flag = 'Y';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF(p_agenda_rec.agenda_type = 'SESSION')
   THEN

      /* Getting the Track Id */
      OPEN  c_parent_id(p_agenda_rec.agenda_id);
      FETCH c_parent_id INTO l_parent_id;
      CLOSE c_parent_id;

      /* Getting the Min start_date_time and Max end_date_time of all Sessions
         attached to the track_id = p_agenda_rec.parent_id
      */
      OPEN  c_min_max_times (p_agenda_rec.parent_id);
      FETCH c_min_max_times INTO l_min_time, l_max_time;
      CLOSE c_min_max_times;

      /* Rolling up times to Track level */
      UPDATE ams_agendas_b
      SET   start_date_time = l_min_time,
            end_date_time   = l_max_time,
            object_version_number = object_version_number + 1
      WHERE agenda_id       = l_parent_id;

      /* Getting the Event Id. l_parent_id contains the Track Id before
         OPEN CURSOR. After FETCHING l_parent_id contains the Event Id
      */
      OPEN  c_parent_id(l_parent_id);
      FETCH c_parent_id INTO l_parent_id;
      CLOSE c_parent_id;

      /* Getting the Min start_date_time and Max end_date_time of all Tracks
         attached to the event_id = l_parent_id.
      */
      OPEN  c_min_max_times (l_parent_id);
      FETCH c_min_max_times INTO l_min_time, l_max_time;
      CLOSE c_min_max_times;

      /* Rolling up times to Event level */
      UPDATE ams_event_offers_all_b
      SET   event_start_date_time = l_min_time,
            event_end_date_time   = l_max_time,
            object_version_number = object_version_number + 1
      WHERE event_offer_id        = l_parent_id;

   ELSIF (p_agenda_rec.agenda_type = 'TRACK')
   THEN

      /* Getting the Event Id */
      OPEN  c_parent_id(p_agenda_rec.agenda_id);
      FETCH c_parent_id INTO l_parent_id;
      CLOSE c_parent_id;

      /* Getting the Min start_date_time and Max end_date_time of all Tracks
         attached to the event_id = p_agenda_rec.parent_id
      */
      OPEN  c_min_max_times (p_agenda_rec.parent_id);
      FETCH c_min_max_times INTO l_min_time, l_max_time;
      CLOSE c_min_max_times;

      /* Rolling up times to Event level */
      UPDATE ams_event_offers_all_b
      SET   event_start_date_time = l_min_time,
            event_end_date_time   = l_max_time,
            object_version_number = object_version_number + 1
      WHERE event_offer_id        = l_parent_id;


    END IF; -- end of p_agenda_rec.agenda_type = 'TRACK'

 END Rollup_StTime_EdTime;

procedure ADD_LANGUAGE
is
begin
  delete from ams_agendas_tl T
  where not exists
    (select NULL
    from ams_agendas_b B
    where B.AGENDA_ID = T.AGENDA_ID
    );

  update ams_agendas_tl T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from ams_agendas_tl B
    where B.AGENDA_ID = T.AGENDA_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.AGENDA_ID,
      T.LANGUAGE
  ) in (select
      SUBT.AGENDA_ID,
      SUBT.LANGUAGE
    from ams_agendas_tl SUBB, ams_agendas_tl SUBT
    where SUBB.AGENDA_ID = SUBT.AGENDA_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.AGENDA_NAME <> SUBT.AGENDA_NAME
     OR  SUBB.DESCRIPTION <> SUBT.DESCRIPTION
     or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
     or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into ams_agendas_tl (
      AGENDA_ID,
      LANGUAGE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      SOURCE_LANG,
      AGENDA_NAME,
      DESCRIPTION,
      SECURITY_GROUP_ID
  ) select
      B.AGENDA_ID,
      L.LANGUAGE_CODE,
      B.CREATION_DATE,
      B.CREATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_LOGIN,
      B.SOURCE_LANG,
      B.AGENDA_NAME,
      B.DESCRIPTION,
      B.SECURITY_GROUP_ID
  from ams_agendas_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ams_agendas_tl T
    where T.AGENDA_ID = B.AGENDA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



END AMS_Agendas_PVT;

/
