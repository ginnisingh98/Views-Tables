--------------------------------------------------------
--  DDL for Package Body AMS_TRIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TRIG_PVT" as
/* $Header: amsvtrgb.pls 120.5 2006/04/20 01:36:53 srivikri noship $*/

--
-- NAME
--   AMS_Trig_PVT
--
-- HISTORY
--   07/26/1999      ptendulk    CREATED
--   10/25/1999        ptendulk    Modified According to new standards
--   02/24/2000      ptendulk    Add the code to update Object Attribute after
--                               Deletion or addition
--   02/26/2000      ptendulk    Modified the Check_Record Procedure
--   02/26/2000      ptendulk    Modified the package to support the timezone
--   07-Aug-2001     soagrawa    Modified Check_Trig_Uk_Items (replaced call to ams_utility_pvt.check_uniqueness
--                               with a manual check)
--   24-sep-2001     soagrawa    Removed security group id from everywhere
--   10-Dec-2002     ptendulk    Modified calculate_system_time api to combine two parameters into one
--   22/apr/03       cgoyal      added notify_flag, EXECUTE_SCHEDULE_FLAG for 11.5.8 backport
--   08-jul-2003     cgoyal      Modified data insertion in ams_triggers_tl for MLS
--   30-jul-2003     anchaudh    modified comparison operator to fix P1 bug# 3064909 in check_trig_record
--   21-aug-2003     soagrawa    Fixed bug 3108929 in check_trig_record
--   27-aug-2003     soagrawa    Fixed bug 3115141 in check_trig_record
--   20-May-2004     dhsingh	 Modified Check_Trig_Uk_Items and c_trig_name_updt for better performance
--   23-Feb-2006     srivikri    Fix for bug 5053838 - Monitor activation CR
G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_Trig_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvtrgb.pls';


-- Debug mode
-- g_debug boolean := FALSE;
-- g_debug boolean := TRUE;

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
---------------------------------- Triggers --------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Calculate_System_Time(
   p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
   x_msg_count         OUT NOCOPY  NUMBER ,
   x_msg_data          OUT NOCOPY  VARCHAR2 ,
   x_return_status     OUT NOCOPY  VARCHAR2 ,

--  Following code is modified by ptendulk combine p_trig_rec and x_trig_rec into one inout para
--  The change is done due to errors introduce due to nocopy changes.
--   p_trig_rec          IN   trig_rec_type ,
--   x_trig_rec          OUT NOCOPY  trig_rec_type ) ;

   px_trig_rec         IN OUT NOCOPY trig_rec_type );

/***************************  PRIVATE ROUTINES  *********************************/

-- Start of Comments
--
-- NAME
--   Create_Trigger
--
-- PURPOSE
--   This procedure is to create a row in ams_triggers table that
-- satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   07/26/1999      ptendulk    created
--   10/25/1999      ptendulk    Modified according to new standards
--   02/24/2000      ptendulk    Add the code to update Object Attribute after addition
--   04/24/2000      ptendulk    Added 6 Date fields and timezone id for timezone support
--  14-Feb-2001      ptendulk    Modified as triggers will have tl table to store name/desc
--  22/apr/03        cgoyal      added notify_flag and execute_schedule_flag for 11.5.8 backport
-- End of Comments

PROCEDURE Create_Trigger
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,

  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,

  p_trig_Rec                 IN     trig_rec_type,
  x_trigger_id               OUT NOCOPY    NUMBER
) IS

   l_api_name      CONSTANT VARCHAR2(30)  := 'Create_Trigger';
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_full_name     CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;


  -- Status Local Variables
   l_return_status          VARCHAR2(1);  -- Return value from procedures
   l_trig_rec               trig_rec_type := p_trig_rec;


   l_trig_count             NUMBER;
   x_rowid                  VARCHAR2(30);

   CURSOR c_trig_seq IS
   SELECT ams_triggers_s.NEXTVAL
   FROM   dual;

   CURSOR c_trig_exists(l_my_trig_id IN NUMBER) IS
   SELECT 1
     FROM dual
    WHERE EXISTS (SELECT 1
   FROM   ams_triggers
                    WHERE trigger_id = l_my_trig_id);

CURSOR c_trig_count(l_my_trig_id IN NUMBER) IS
   SELECT COUNT(1)
   FROM   ams_triggers
   WHERE  trigger_id = l_my_trig_id;

  BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Create_Trig_PVT;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   --
   -- Perform the database operation
   --

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': validate');

   END IF;

   Validate_Trigger
       ( p_api_version       =>   1.0
        ,p_init_msg_list     =>   p_init_msg_list
        ,p_validation_level  =>   p_validation_level
        ,x_return_status     =>   l_return_status
        ,x_msg_count         =>   x_msg_count
        ,x_msg_data          =>   x_msg_data

        ,p_trig_rec          =>   l_trig_rec
          );

   --
   -- If any errors happen abort API.
   --
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Following code is added by ptendulk on 26 Apr 2000 Give call to
   -- Calculate System time api which will calculate the system date
   -- for the user dates entered.
   Calculate_System_Time(
      p_init_msg_list     =>   p_init_msg_list,
      x_msg_count         =>   x_msg_count,
      x_msg_data          =>   x_msg_data,
      x_return_status     =>   x_return_status,

--  Following code is modified by ptendulk combine p_trig_rec and x_trig_rec into one inout para
--  The change is done due to errors introduce due to nocopy changes.
--      p_trig_rec          =>   p_trig_rec ,
--      x_trig_rec          =>   l_trig_rec ) ;
      px_trig_rec         =>   l_trig_rec );

   --
   -- If any errors happen abort API.
   --
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Insert the Record
   --
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_Utility_PVT.debug_message(l_full_name ||': insert Trigger');
        END IF;
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_Utility_PVT.debug_message('Convert the system time'||p_trig_rec.arc_trigger_created_for||p_trig_rec.trigger_created_for_id);
        END IF;

   --
   -- Find Unique Trigger ID if not sent
   --
   IF l_trig_rec.trigger_id IS NULL OR l_trig_rec.trigger_id = FND_API.G_MISS_NUM
   THEN
      LOOP
         OPEN c_trig_seq;
         FETCH c_trig_seq INTO l_trig_rec.trigger_id;
         CLOSE c_trig_seq;

         AMS_Utility_PVT.debug_message(l_full_name ||': insert Trigger id is '||l_trig_rec.trigger_id);

         OPEN c_trig_exists(l_trig_rec.trigger_id);
         FETCH c_trig_exists INTO l_trig_count;
         CLOSE c_trig_exists;

         AMS_Utility_PVT.debug_message(l_full_name ||': insert Trigger count is '||l_trig_count);

         EXIT WHEN l_trig_count IS null;
      END LOOP;
   END IF;


   INSERT INTO ams_triggers
            (trigger_id
            -- standard who columns
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,object_version_number
            ,process_id
            ,trigger_created_for_id
            ,arc_trigger_created_for
            ,triggering_type
            ,trigger_name
            ,view_application_id
            ,timezone_id
            ,user_start_date_time
            ,start_date_time
            ,user_last_run_date_time
            ,last_run_date_time
            ,user_next_run_date_time
            ,next_run_date_time
            ,user_repeat_daily_start_time
            ,repeat_daily_start_time
            ,user_repeat_daily_end_time
            ,repeat_daily_end_time
            ,repeat_frequency_type
            ,repeat_every_x_frequency
            ,user_repeat_stop_date_time
            ,repeat_stop_date_time
            ,metrics_refresh_type
            ,description
            -- removed by soagrawa on 24-sep-2001
            -- ,security_group_id
	    --added by cgoyal for 11.5.8 backport
	    ,notify_flag
	    ,execute_schedule_flag
	    ,TRIGGERED_STATUS --anchaudh added for monitors,R12.
            ,USAGE --anchaudh added for monitors,R12.
   )
   VALUES
   (
            l_trig_rec.trigger_id
   -- standard who columns
            ,SYSDATE
            ,FND_GLOBAL.User_Id
            ,SYSDATE
            ,FND_GLOBAL.User_Id
            ,FND_GLOBAL.Conc_Login_Id

            ,1                                     -- Object Version Number
            ,l_trig_rec.process_id
            ,l_trig_rec.trigger_created_for_id
            ,l_trig_rec.arc_trigger_created_for
            ,l_trig_rec.triggering_type
            ,NULL                                  -- As trigger name will be stored in the tl table
            ,l_trig_rec.view_application_id
            ,l_trig_rec.timezone_id
            ,l_trig_rec.user_start_date_time
            ,l_trig_rec.start_date_time
            ,l_trig_rec.user_last_run_date_time
            ,l_trig_rec.last_run_date_time
            ,l_trig_rec.user_next_run_date_time
            ,l_trig_rec.next_run_date_time
            ,l_trig_rec.user_repeat_daily_start_time
            ,l_trig_rec.repeat_daily_start_time
            ,l_trig_rec.user_repeat_daily_end_time
            ,l_trig_rec.repeat_daily_end_time
            ,l_trig_rec.repeat_frequency_type
            ,l_trig_rec.repeat_every_x_frequency
            ,l_trig_rec.user_repeat_stop_date_time
            ,l_trig_rec.repeat_stop_date_time
            ,l_trig_rec.metrics_refresh_type
            ,NULL                                   -- As Description will be stored in tl table.
            -- removed by soagrawa on 24-sep-2001
            -- ,l_trig_rec.security_group_id
            --added by cgoyal for 11.5.8 backport
            ,nvl(l_trig_rec.notify_flag,'N')
            ,nvl(l_trig_rec.execute_schedule_flag,'N')
	    ,l_trig_rec.TRIGGERED_STATUS--anchaudh added for monitors,R12.
	    ,l_trig_rec.USAGE--anchaudh added for monitors,R12.
              );
--cgoyal commented on 08/03 for MLS
/*
   INSERT INTO ams_triggers_tl
      (trigger_id
      ,language
      ,last_update_date
      ,last_upated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,source_lang
      ,trigger_name
      ,description
      -- removed by soagrawa on 24-sep-2001
      -- ,security_group_id
      )
   VALUES
      (l_trig_rec.trigger_id
      ,USERENV('LANG')
      ,SYSDATE
      ,FND_GLOBAL.User_Id
      ,SYSDATE
      ,FND_GLOBAL.User_Id
      ,FND_GLOBAL.Conc_Login_Id
      ,USERENV('LANG')
      ,l_trig_rec.trigger_name
      ,l_trig_rec.description
      -- removed by soagrawa on 24-sep-2001
      -- ,l_trig_rec.security_group_id
      ) ;
*/
   INSERT INTO ams_triggers_tl
      (trigger_id
      ,language
      ,last_update_date
      ,last_upated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,source_lang
      ,trigger_name
      ,description
      -- removed by soagrawa on 24-sep-2001
      -- ,security_group_id
      )
   SELECT
           l_trig_rec.trigger_id,
           l.language_code,
           SYSDATE,
           FND_GLOBAL.user_id,
           SYSDATE,
           FND_GLOBAL.user_id,
           FND_GLOBAL.conc_login_id,
           USERENV('LANG'),
           l_trig_rec.trigger_name,
           l_trig_rec.description
   FROM    fnd_languages l
   WHERE   l.installed_flag IN ('I','B')
   AND     NOT EXISTS(
                      SELECT NULL
                      FROM   ams_triggers_tl t
                      WHERE  t.trigger_id = l_trig_rec.trigger_id
                      AND    t.language = l.language_code ) ;

    AMS_Utility_PVT.debug_message(l_full_name ||': inserted in tl table');


   -- Following code has been added by ptendulk on 24Feb2000
   -- It will update the attribute in ams_object_attribites
   -- as soon as segment is created for an activity

   -- Following code is commented by ptendulk on 14-Feb-2001
   --  As from hornet release cue card attributes won't be stored in obj attr table.
   -- indicate schedule has been defined for the campaign
   --IF l_trig_rec.arc_trigger_created_for <> 'AMET' THEN
   --   AMS_ObjectAttribute_PVT.modify_object_attribute(
   --      p_api_version        => l_api_version,
   --      p_init_msg_list      => FND_API.g_false,
   --      p_commit             => FND_API.g_false,
   --      p_validation_level   => FND_API.g_valid_level_full,
   --      x_return_status      => l_return_status,
   --      x_msg_count          => x_msg_count,
   --      x_msg_data           => x_msg_data,

   --      p_object_type        => l_trig_rec.arc_trigger_created_for,
   --      p_object_id          => l_trig_rec.trigger_created_for_id,
   --      p_attr               => 'TRIG',
   --      p_attr_defined_flag  => 'Y' );
   --
   --   IF l_return_status = FND_API.g_ret_sts_error THEN
   --      RAISE FND_API.g_exc_error;
   --    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
   --      RAISE FND_API.g_exc_unexpected_error;
   --   END IF;

   --END IF;

   --
   -- set OUT value
   --
   x_trigger_id := l_trig_rec.trigger_id;

   --
   -- END of API body.
   --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
       COMMIT WORK;
    END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data,
        p_encoded         =>      FND_API.G_FALSE
        );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Create_Trig_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;

         FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded         =>      FND_API.G_FALSE
            );


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Create_Trig_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded         =>      FND_API.G_FALSE
            );

   WHEN OTHERS THEN

      ROLLBACK TO Create_Trig_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;

         FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
              p_encoded         =>      FND_API.G_FALSE
             );
END Create_Trigger;

-- Start of Comments
--
-- NAME
--   Delete_Trigger
--
-- PURPOSE
--   This procedure is to delete a ams_triggers table that satisfy caller needs
--
-- NOTES
--  Buss. Rule : If the trigger is not repeating , delete trigger
--   If it is repeating , Delete trigger only if it hasn't run yet.
--   If it has run before Update the repeat_stop_date time with sysdate to
--   deactivate trigger
--  24-Apr-2001    soagrawa
--  New Business Rule:
--    If exist schedule(s) associated with the trigger => do not delete, just deactivate
--    If trigger has not run yet => delete
--    If trigger has run         => deactivate
--
--  23-Feb-2006 srivikri
--  New buisiness rule:
--  Trigger can be activated by the user using an activate button
--  If trigger has not been activated => delete
--  If trigger is activated => do not delete
--  Refer bug 5053838
--
--
-- HISTORY
--   07/26/1999      ptendulk    created
--   10/25/1999      ptendulk    Modified according to new API standards
--   02/24/2000      ptendulk    Add the code to update Object Attribute after
--                               Deletion
--  14-Feb-2001      ptendulk    Modified as triggers will have tl table to store name/desc
--  24-Apr-2001      soagrawa    Modified as per the new business rules
--  23-Feb-2006      srivikri    Modified as per new buisiness rules - refer bug 5053838
-- End of Comments

PROCEDURE Delete_Trigger
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                    IN     VARCHAR2    := FND_API.G_FALSE,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_id                IN     NUMBER,
  p_object_version_number     IN     NUMBER
) IS

  l_api_name       CONSTANT VARCHAR2(30)  := 'Delete_Trigger';
  l_api_version    CONSTANT NUMBER        := 1.0;
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status  VARCHAR2(1);

  CURSOR c_trig_det IS
  SELECT repeat_frequency_type,
         last_run_date_time,
         arc_trigger_created_for,
         trigger_created_for_id,
         timezone_id,
         start_date_time,
         process_id
  FROM   ams_triggers
  WHERE  trigger_id = p_trigger_id ;

  /*CURSOR c_assoc_sch IS
  SELECT count(*)
  FROM   ams_campaign_schedules_b
  WHERE  trigger_id = p_trigger_id;
  */
  l_trig_rec    c_trig_det%ROWTYPE ;
  l_mode        VARCHAR2(30);
  l_dummy       NUMBER;
  l_user_date   date ;
  l_assoc_sch   NUMBER;


BEGIN
  --
  -- Standard Start of API savepoint
  --
   SAVEPOINT Delete_Trig_PVT;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;
     -- dbms_output.put_line('entered API Call');
     --       dbms_output.put_line('trigger ID to be deleted is ');
     --             dbms_output.put_line(p_trigger_id);
   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   --
   -- API body
   --
   OPEN c_trig_det ;
   FETCH c_trig_det INTO l_trig_rec ;
   CLOSE c_trig_det ;


   -----------------------------------------------------------------------
   -- Following code is added by soagrawa on 04/24/01
   -- Business rules for delete trigger have been modified
   -- need to know if there are any schedules associated with the trigger
   -----------------------------------------------------------------------

   SELECT count(*)
   INTO l_assoc_sch -- number of schedules associated with this triggerId
   FROM   ams_campaign_schedules_b
   WHERE  trigger_id = p_trigger_id;

   -------------------------------------------------------
   -- Following code is modified by soagrawa on 13-may-2003
   -- Business rules for delete trigger have been modified
   -------------------------------------------------------

   AMS_Utility_PVT.Create_Log (
         x_return_status   => l_return_status,
         p_arc_log_used_by => 'TRIG',
         p_log_used_by_id  => p_trigger_id,
         p_msg_data        => 'l_assoc_sch:'||l_assoc_sch,
         p_msg_type        => 'DEBUG'
         );
   IF l_assoc_sch>0 THEN  -- if exist schedule(s) associated with this triggerId
           -- throw error msg
            AMS_Utility_PVT.Error_Message('AMS_TRIG_NO_DEL_CSC_ASSOC');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   ELSE  -- no schedules are associated with this trigger
        AMS_Utility_PVT.Create_Log (
               x_return_status   => l_return_status,
               p_arc_log_used_by => 'TRIG',
               p_log_used_by_id  => p_trigger_id,
               p_msg_data        => 'process_id:'||l_trig_rec.process_id,
               p_msg_type        => 'DEBUG'
               );

        IF (l_trig_rec.process_id IS NULL OR l_trig_rec.process_id = '') THEN -- if trigger has not started yet

            DELETE FROM AMS_triggers_tl
            WHERE trigger_id = p_trigger_id ;
            IF (SQL%NOTFOUND) THEN
               AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            AMS_Utility_PVT.Create_Log (
                  x_return_status   => l_return_status,
                  p_arc_log_used_by => 'TRIG',
                  p_log_used_by_id  => p_trigger_id,
                  p_msg_data        => 'going to delete trigger_id:'||p_trigger_id,
                  p_msg_type        => 'DEBUG'
                  );

            DELETE FROM ams_triggers
            WHERE  trigger_id = p_trigger_id
            AND    object_version_number = p_object_version_number ;

            IF (SQL%NOTFOUND) THEN
               AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
               RAISE FND_API.G_EXC_ERROR;
            ELSE
            -- Delete the Checks and Actions Attached to the Trigger
               DELETE FROM ams_trigger_checks
               WHERE       trigger_id = p_trigger_id ;

               DELETE FROM ams_trigger_actions
               WHERE       trigger_id = p_trigger_id ;

            END IF;


        ELSE  -- if trigger has started
           -- throw error msg
            AMS_Utility_PVT.Error_Message('AMS_TRIG_NO_DEL_TRIG_ACTIVE');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


        END IF;
   END IF;

   --
   -- END of API body.
   --

   --
   -- Standard check of p_commit.
   --
    --    dbms_output.put_line('commit : '||p_commit);
   IF FND_API.To_Boolean ( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data,
        p_encoded         =>      FND_API.G_FALSE
        );

   --
   -- Debug message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Delete_Trig_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;

         FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded         =>      FND_API.G_FALSE
            );


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Delete_Trig_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded         =>      FND_API.G_FALSE
            );


   WHEN OTHERS THEN

      ROLLBACK TO Delete_Trig_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
         THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;

         FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
         );

END Delete_Trigger;

-- Start of Comments
--
-- NAME
--   Lock_Trigger
--
-- PURPOSE
--   This procedure is to lock a ams_triggers table that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999        ptendulk      created
--   10/25/1999        ptendulk      Modified according to new API standards
-- End of Comments

PROCEDURE Lock_Trigger
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_id                IN     NUMBER,
  p_object_version_number     IN     NUMBER
) IS

   l_api_name     CONSTANT VARCHAR2(30) := 'Lock_Trigger';
   l_api_version  CONSTANT NUMBER       := 1.0;
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   -- Status Local Variables
   l_trigger_id   NUMBER;

   CURSOR C_ams_triggers IS
      SELECT trigger_id
      FROM   ams_triggers
      WHERE  trigger_id = p_trigger_id
      AND    object_version_number = p_object_version_number
      FOR UPDATE of trigger_id NOWAIT;

   CURSOR c_trig_tl IS
   SELECT trigger_id
     FROM ams_triggers_tl
    WHERE trigger_id = p_trigger_id
      AND USERENV('LANG') IN (language, source_lang)
   FOR UPDATE NOWAIT;

BEGIN

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': lock');

   END IF;


   -- Perform the database operation
   OPEN  C_ams_triggers;
   FETCH C_ams_triggers INTO l_trigger_id ;
   IF (C_ams_triggers%NOTFOUND) THEN
      CLOSE C_ams_triggers;
      -- Error, check the msg level and added an error message to the
      -- API message list
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('FND', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE C_ams_triggers;

   OPEN  c_trig_tl ;
   CLOSE c_trig_tl ;

   --
   -- END of API body.
   --

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data,
        p_encoded         =>      FND_API.G_FALSE
        );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_AND_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data,
        p_encoded         =>      FND_API.G_FALSE
        );

   WHEN AMS_Utility_PVT.RESOURCE_LOCKED  THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.SET_NAME('AMS','AMS_API_RESOURCE_LOCKED');
         FND_MSG_PUB.Add;
      END IF;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded         =>      FND_API.G_FALSE
                );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );
END Lock_Trigger;

-- Start of Comments
--
-- NAME
--   Update_Trigger
--
-- PURPOSE
--   This procedure is to update a ams_triggers table that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   07/26/1999   ptendulk    created
--   10/25/1999   ptendulk    Modified According to new API standards
--   04/24/2000   ptendulk    Added 6 User date fields and time zone id for
--                            timezone support
--   22/apr/03    cgoyal      added notify_flag and execute_schedule_flag for 11.5.8 backport
-- End of Comments

PROCEDURE Update_Trigger
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit              IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level    IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,

  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,

  p_trig_rec            IN     trig_rec_type
) IS

   l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Trigger';
   l_api_version        CONSTANT NUMBER        := 1.0;
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   -- Status Local Variables
   l_return_status      VARCHAR2(1);  -- Return value from procedures
   l_trig_rec           trig_rec_type := p_trig_rec;

   CURSOR c_trig IS
   SELECT repeat_frequency_type,last_run_date_time,
          repeat_stop_date_time
   FROM   ams_triggers
   WHERE  trigger_id = p_trig_rec.trigger_id ;

   l_trig_det_rec       c_trig%ROWTYPE;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   SAVEPOINT Update_Trig_PVT;

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': Validate');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_trig_items(
         p_trig_rec        => p_trig_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );
--dbms_output.put_line('After Item Validation : '||l_return_status);
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- replace g_miss_char/num/date with current column values
   complete_trig_rec(p_trig_rec, l_trig_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_trig_record(
         p_trig_rec       => p_trig_rec,
         p_complete_rec   => l_trig_rec,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   --dbms_output.put_line('After Validation : '||l_return_status);

   -- Don't allow to update if the sysdate is greater than Repeat stop date
   OPEN c_trig ;
   FETCH c_trig INTO l_trig_det_rec ;
   CLOSE c_trig ;

   IF l_trig_det_rec.repeat_frequency_type = 'NONE' THEN
      IF l_trig_det_rec.last_run_date_time IS NOT NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_TRIG_ERR_UPDT_TRIG_FIRED');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
      IF l_trig_det_rec.repeat_stop_date_time < SYSDATE THEN
         AMS_Utility_PVT.Error_Message('AMS_TRIG_ERR_UPDT_EXPIRED');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- Following code is added by ptendulk on 26 Apr 2000 Give call to
   -- Calculate System time api which will calculate the system date
   -- for the user dates entered.

   Calculate_System_Time(
      p_init_msg_list     => p_init_msg_list,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      x_return_status     => x_return_status,
--  Following code is modified by ptendulk combine p_trig_rec and x_trig_rec into one inout para
--  The change is done due to errors introduce due to nocopy changes.
--      p_trig_rec          => l_trig_rec ,
--      x_trig_rec          => l_trig_rec ) ;
      px_trig_rec         => l_trig_rec );

   --
   --Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;

   UPDATE ams_triggers
   SET
      last_update_date                = SYSDATE
      ,last_updated_by                = FND_GLOBAL.user_id
      ,last_update_login              = FND_GLOBAL.conc_login_id
      ,object_version_number          = l_trig_rec.object_version_number + 1
      ,process_id                     = l_trig_rec.process_id
      ,trigger_created_for_id         = l_trig_rec.trigger_created_for_id
      ,arc_trigger_created_for        = l_trig_rec.arc_trigger_created_for
      ,triggering_type                = l_trig_rec.triggering_type
      ,trigger_name                   = NULL          -- As Name will be stored in tl table.
      ,view_application_id            = l_trig_rec.view_application_id
      ,timezone_id                    = l_trig_rec.timezone_id
      ,user_start_date_time           = l_trig_rec.user_start_date_time
      ,start_date_time                = l_trig_rec.start_date_time
      ,user_last_run_date_time        = l_trig_rec.user_last_run_date_time
      ,last_run_date_time             = l_trig_rec.last_run_date_time
      ,user_next_run_date_time        = l_trig_rec.user_next_run_date_time
      ,next_run_date_time             = l_trig_rec.next_run_date_time
      ,user_repeat_daily_start_time   = l_trig_rec.user_repeat_daily_start_time
      ,repeat_daily_start_time        = l_trig_rec.repeat_daily_start_time
      ,user_repeat_daily_end_time     = l_trig_rec.user_repeat_daily_end_time
      ,repeat_daily_end_time          = l_trig_rec.repeat_daily_end_time
      ,repeat_frequency_type          = l_trig_rec.repeat_frequency_type
      ,repeat_every_x_frequency       = l_trig_rec.repeat_every_x_frequency
      ,user_repeat_stop_date_time     = l_trig_rec.user_repeat_stop_date_time
      ,repeat_stop_date_time          = l_trig_rec.repeat_stop_date_time
      ,metrics_refresh_type           = l_trig_rec.metrics_refresh_type
      ,description                    = null            -- As description will be stored in tl table.
      -- removed by soagrawa on 24-sep-2001
      -- ,security_group_id              = l_trig_rec.security_group_id
      ,notify_flag                    = l_trig_rec.notify_flag
      ,execute_schedule_flag          = l_trig_rec.execute_schedule_flag
      ,TRIGGERED_STATUS    = l_trig_rec.TRIGGERED_STATUS--anchaudh added for monitors,R12
      ,USAGE               = l_trig_rec.USAGE--anchaudh added for monitors,R12

   WHERE trigger_id = l_trig_rec.trigger_id
   AND   object_version_number = l_trig_rec.object_version_number ;

   IF (SQL%NOTFOUND) THEN
      AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;

   UPDATE ams_triggers_tl
   SET
      last_update_date                = SYSDATE,
      last_upated_by                  = FND_GLOBAL.user_id,
      creation_date                   = SYSDATE,
      created_by                      = FND_GLOBAL.user_id,
      last_update_login               = FND_GLOBAL.user_id,
      source_lang                     = USERENV('LANG'),
      trigger_name                    = l_trig_rec.trigger_name,
      description                     = l_trig_rec.description
      -- removed by soagrawa on 24-sep-2001
      -- security_group_id               = l_trig_rec.security_group_id
   WHERE trigger_id = l_trig_rec.trigger_id ;
   IF (SQL%NOTFOUND) THEN
      AMS_Utility_PVT.Error_Message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   --
   -- END of API body.
   --

   --
   -- Standard check of p_commit.
   --
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );


   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Update_Trig_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;

         FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded         =>      FND_API.G_FALSE
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Update_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_AND_Get
          ( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data,
            p_encoded         =>      FND_API.G_FALSE
            );

   WHEN OTHERS THEN

      ROLLBACK TO Update_Trig_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded         =>      FND_API.G_FALSE
            );
END Update_Trigger;


-- Start of Comments
--
-- NAME
--   Calculate_System_Time
--
-- PURPOSE
--   This procedure accepts the trigger record and calculates the system time
--   for all the user entered times. It convert the time from user's timezone to
--   the server's timezone
--
-- NOTES
--
--
-- HISTORY
--   10/25/1999        ptendulk            created
--   10-Dec-2002        ptendulk   Modified the api parameters
-- End of Comments
PROCEDURE Calculate_System_Time(
   p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
   x_msg_count         OUT NOCOPY  NUMBER ,
   x_msg_data          OUT NOCOPY  VARCHAR2 ,
   x_return_status     OUT NOCOPY  VARCHAR2 ,

--  Following code is modified by ptendulk combine p_trig_rec and x_trig_rec into one inout para
--  The change is done due to errors introduce due to nocopy changes.
   --p_trig_rec          IN   trig_rec_type ,
   --x_trig_rec          IN OUT NOCOPY  trig_rec_type )
   px_trig_rec         IN OUT NOCOPY trig_rec_type)
IS
   l_trig_rec trig_rec_type := px_trig_rec ;

BEGIN
   IF px_trig_rec.usage <> 'MONITOR' THEN
   -- USAGE IS TRIGGER
      IF px_trig_rec.user_start_date_time <> FND_API.G_MISS_DATE
      THEN
         AMS_UTILITY_PVT.Convert_Timezone(
                      p_init_msg_list   => p_init_msg_list ,
                      x_return_status   => x_return_status ,
                      x_msg_count       => x_msg_count   ,
                      x_msg_data        => x_msg_data   ,

                      p_user_tz_id        => l_trig_rec.timezone_id   ,  -- required
                      p_in_time         => l_trig_rec.user_start_date_time   ,-- required

                      x_out_time        => l_trig_rec.start_date_time
         );

      END IF;

      IF px_trig_rec.user_repeat_daily_start_time <> FND_API.G_MISS_DATE
      THEN
              AMS_UTILITY_PVT.Convert_Timezone(
                      p_init_msg_list   => p_init_msg_list ,
                      x_return_status   => x_return_status ,
                      x_msg_count       => x_msg_count   ,
                      x_msg_data        => x_msg_data   ,

                      p_user_tz_id        => l_trig_rec.timezone_id   ,  -- required
                      p_in_time         => l_trig_rec.user_repeat_daily_start_time   ,-- required

                      x_out_time        => l_trig_rec.repeat_daily_start_time
                       );
      END IF ;

      IF px_trig_rec.user_repeat_daily_end_time <> FND_API.G_MISS_DATE
      THEN
              AMS_UTILITY_PVT.Convert_Timezone(
                      p_init_msg_list   => p_init_msg_list ,
                      x_return_status   => x_return_status ,
                      x_msg_count       => x_msg_count   ,
                      x_msg_data        => x_msg_data   ,

                      p_user_tz_id        => l_trig_rec.timezone_id   ,  -- required
                      p_in_time       => l_trig_rec.user_repeat_daily_end_time   ,-- required

                      x_out_time        => l_trig_rec.repeat_daily_end_time
                       );
      END IF ;

      IF px_trig_rec.user_repeat_stop_date_time <> FND_API.G_MISS_DATE
      THEN
              AMS_UTILITY_PVT.Convert_Timezone(
                      p_init_msg_list   => p_init_msg_list ,
                      x_return_status   => x_return_status ,
                      x_msg_count       => x_msg_count   ,
                      x_msg_data        => x_msg_data   ,

                      p_user_tz_id        => l_trig_rec.timezone_id   ,  -- required
                      p_in_time         => l_trig_rec.user_repeat_stop_date_time   ,-- required

                      x_out_time        => l_trig_rec.repeat_stop_date_time
                       );

      END IF ;
   ELSE
   -- FOR MONITORS, THE TIMEZONE CONVERSION IS DONE BY OA.
   -- SO, THE REVERSE CONVERSION HAS TO BE DONE TO POPULATE user_date_time fields
      IF px_trig_rec.start_date_time <> FND_API.G_MISS_DATE
      THEN
         AMS_UTILITY_PVT.Convert_Timezone(
                      p_init_msg_list   => p_init_msg_list ,
                      x_return_status   => x_return_status ,
                      x_msg_count       => x_msg_count   ,
                      x_msg_data        => x_msg_data   ,
                      p_user_tz_id        => l_trig_rec.timezone_id   ,
                      p_in_time         => l_trig_rec.start_date_time  ,
                      p_convert_type    => 'USER' ,
                      x_out_time        => l_trig_rec.user_start_date_time
         );

      END IF;

      IF px_trig_rec.repeat_daily_start_time <> FND_API.G_MISS_DATE
      THEN
              AMS_UTILITY_PVT.Convert_Timezone(
                      p_init_msg_list   => p_init_msg_list ,
                      x_return_status   => x_return_status ,
                      x_msg_count       => x_msg_count   ,
                      x_msg_data        => x_msg_data   ,
                      p_user_tz_id        => l_trig_rec.timezone_id   ,
                      p_in_time         => l_trig_rec.repeat_daily_start_time   ,
                      p_convert_type    => 'USER' ,
                      x_out_time        => l_trig_rec.user_repeat_daily_start_time
                       );
      END IF ;

      IF px_trig_rec.repeat_daily_end_time <> FND_API.G_MISS_DATE
      THEN
              AMS_UTILITY_PVT.Convert_Timezone(
                      p_init_msg_list   => p_init_msg_list ,
                      x_return_status   => x_return_status ,
                      x_msg_count       => x_msg_count   ,
                      x_msg_data        => x_msg_data   ,
                      p_user_tz_id        => l_trig_rec.timezone_id   ,
                      p_in_time       => l_trig_rec.repeat_daily_end_time   ,
                      p_convert_type    => 'USER' ,
                      x_out_time        => l_trig_rec.user_repeat_daily_end_time
                       );
      END IF ;

      IF px_trig_rec.repeat_stop_date_time <> FND_API.G_MISS_DATE
      THEN
              AMS_UTILITY_PVT.Convert_Timezone(
                      p_init_msg_list   => p_init_msg_list ,
                      x_return_status   => x_return_status ,
                      x_msg_count       => x_msg_count   ,
                      x_msg_data        => x_msg_data   ,
                      p_user_tz_id        => l_trig_rec.timezone_id   ,
                      p_in_time         => l_trig_rec.repeat_stop_date_time   ,
                      p_convert_type    => 'USER' ,
                      x_out_time        => l_trig_rec.user_repeat_stop_date_time
                       );

      END IF ;
   END IF;
px_trig_rec := l_trig_rec ;
END Calculate_System_Time ;



-- Start of Comments
--
-- NAME
--   Validate_Trigger
--
-- PURPOSE
--   This procedure is to check required parameters that satisfy caller needs.
--
-- NOTES
--
--
-- HISTORY
--   07/26/1999        ptendulk         created
--   10/25/1999        ptendulk         Modified according to new API standards
-- End of Comments

PROCEDURE Validate_Trigger(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_trig_rec          IN  trig_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Trigger';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

BEGIN

   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate Trigger Items ------------------------
   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Check_Trig_Items(
         p_trig_rec        => p_trig_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );
--dbms_output.put_line('Stat After Item : '||l_return_status);
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   ---------------------- validate Trigger Records ------------------------
   --
   -- Debug Message
   --
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': check record');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Check_Trig_Record(
         p_trig_rec       => p_trig_rec,
         p_complete_rec   => NULL,
         x_return_status  => l_return_status
      );
--dbms_output.put_line('Stat After Record : '||l_return_status);
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Validate_Trigger;



-- Start of Comments
--
-- NAME
----   Check_Trig_Req_Items
--
-- PURPOSE
--   This procedure is to check required parameters that satisfy caller needs.
--
-- NOTES
--
--
-- HISTORY
--   07/26/1999        ptendulk       created
--   10/25/1999        ptendulk       Modified according to new standards
-- End of Comments

PROCEDURE Check_Trig_Req_Items
( p_trig_rec                IN     trig_rec_type,
  x_return_status           OUT NOCOPY    VARCHAR2
) IS

BEGIN
    --  Initialize API/Procedure return status to success
   x_return_status := FND_API.G_Ret_Sts_Success;
   --
    -- Trigger Created For ID
   --
   IF p_trig_rec.trigger_created_for_id IS NULL
   THEN
      -- missing required field
      AMS_UTILITY_PVT.Error_Message('AMS_TRIG_MISSING_CREATED_FOR');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;

   --
   -- Trigger Created for
   --
   IF p_trig_rec.arc_trigger_created_for IS NULL
   THEN
      AMS_UTILITY_PVT.Error_Message('AMS_TRIG_MISSING_CREATED_FOR');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;

   --
   -- Triggering type
   --
   IF p_trig_rec.triggering_type IS NULL
   THEN
      AMS_UTILITY_PVT.Error_Message('AMS_TRIG_MISSING_TRIG_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;

   --
   -- Repeat Frequency Type
   --
   IF p_trig_rec.repeat_frequency_type IS NULL
   THEN
      AMS_UTILITY_PVT.Error_Message('AMS_TRIG_MISSING_REP_FREQ_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;

   --
   -- Trigger Name
   --
   IF p_trig_rec.trigger_name IS NULL
   THEN
      AMS_UTILITY_PVT.Error_Message('AMS_TRIG_MISSING_TRIG_NAME');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;

   --
   -- Application ID
   --
   IF p_trig_rec.view_application_id IS NULL
   THEN
      AMS_UTILITY_PVT.Error_Message('AMS_API_MISSING_APP_ID');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;

   --
   -- Start Date time
   --
   IF p_trig_rec.user_start_date_time IS NULL
   THEN
      AMS_UTILITY_PVT.Error_Message('AMS_TRIG_MISSING_START_DT');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;

   --
   -- Start Date time
   --
   IF p_trig_rec.timezone_id IS NULL
   THEN
      AMS_UTILITY_PVT.Error_Message('AMS_TRIG_MISSING_TIMEZONE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;

END Check_Trig_Req_Items;

-- Start of Comments
--
-- NAME
--   Validate_Trig_UK_Items
--
-- PURPOSE
--   This procedure is to validate ams_triggers items
--
-- NOTES
--
--
-- HISTORY
--   25-oct-1999        ptendulk            created
--   07-aug-2001        soagrawa            Replaced call to ams_utility_pvt.check_uniqueness with manual check
-- End of Comments

PROCEDURE Check_Trig_Uk_Items(
   p_trig_rec        IN  trig_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag      VARCHAR2(1);
   l_where_clause    VARCHAR2(2000);

   -- following 2 cursors c_trig_name , c_trig_name_updt added by soagrawa on 07-Aug-2001
   -- to replace call to Ams_Utility_Pvt.check_uniqueness
   CURSOR c_trig_name IS
--   modified by dhsingh on 20.05.2004 for bug# 3631107
--   SELECT 1 from dual
--   WHERE EXISTS (SELECT *
--                 FROM  AMS_TRIGGERS_VL
--                 WHERE UPPER(TRIGGER_NAME) = UPPER(p_trig_rec.trigger_name));
	SELECT 1 from dual
	WHERE EXISTS (SELECT *
		FROM  AMS_TRIGGERS_TL
		WHERE UPPER(TRIGGER_NAME) = UPPER(p_trig_rec.trigger_name)
		AND   language = USERENV('LANG'));
--  end of modification by dhsingh

   CURSOR c_trig_name_updt IS
--   modified by dhsingh on 20.05.2004 for bug# 3631107
--   SELECT 1 from dual
--   WHERE EXISTS (SELECT *
--                 FROM  AMS_TRIGGERS_VL
--                 WHERE UPPER(TRIGGER_NAME) = UPPER(p_trig_rec.trigger_name)
--                 AND   TRIGGER_ID <> p_trig_rec.trigger_id);
	SELECT 1 from dual
	WHERE EXISTS (SELECT *
		FROM  AMS_TRIGGERS_TL
		WHERE UPPER(TRIGGER_NAME) = UPPER(p_trig_rec.trigger_name)
		AND   TRIGGER_ID <> p_trig_rec.trigger_id
		AND   language = USERENV('LANG'));
--  end of modification by dhsingh

   l_dummy  NUMBER ;
   -- end soagrawa 07-Aug-2001

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_trigger, when trigger_id is passed in, we need to
   -- check if this trigger_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_trig_rec.trigger_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
              'AMS_TRIGGERS',
              'TRIGGER_ID = ' || p_trig_rec.trigger_id
      ) = FND_API.g_false
      THEN
         AMS_UTILITY_PVT.Error_Message('AMS_TRIG_DUP_TRIG_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Check if Trigger_name is unique. Need to handle create and
   -- update differently.

   -- modified by soagrawa on 07-aug-2001
   -- replaced use of ams_utility_pvt.check_uniqueness by manual check
   -- due to bug in check_uniqueness - does not handle AND in the condition
   /*
   -- Unique TRIGGER_NAME and TRIGGER_CREATED_FOR
   l_where_clause := ' UPPER(TRIGGER_NAME) = ''' || UPPER(p_trig_rec.trigger_name)||'''' ;

   -- For Updates, must also check that uniqueness is not checked against the same record.
   IF p_validation_mode <> JTF_PLSQL_API.g_create THEN
      l_where_clause := l_where_clause || ' AND TRIGGER_ID <> ' || p_trig_rec.trigger_id;
   END IF;

   IF AMS_Utility_PVT.Check_Uniqueness(
         p_table_name      => 'AMS_TRIGGERS_VL',
      p_where_clause    => l_where_clause
      ) = FND_API.g_false
   THEN
      AMS_UTILITY_PVT.Error_Message('AMS_TRIG_DUP_TRIG_NAME');
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   */

   IF p_validation_mode = JTF_PLSQL_API.g_update THEN
         OPEN c_trig_name_updt;
         FETCH c_trig_name_updt INTO l_dummy ;
         CLOSE c_trig_name_updt ;
   ELSE
         OPEN c_trig_name;
         FETCH c_trig_name INTO l_dummy ;
         CLOSE c_trig_name ;
   END IF ;

   IF l_dummy IS NOT NULL THEN
         -- Duplicate Trigger
         AMS_Utility_PVT.Error_Message('AMS_TRIG_DUP_TRIG_NAME');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
   END IF ;

   -- end changes soagrawa 07-Aug-2001



END Check_Trig_Uk_Items;


-- Start of Comments
--
-- NAME
--   Check_Trig_fk_Items
--
-- PURPOSE
--   This procedure is to validate ams_triggers items
--    It will validates the Foreign keys
--
-- NOTES
--
--
-- HISTORY
--   10/25/1999        ptendulk            created
-- End of Comments
PROCEDURE Check_Trig_fk_Items
   ( p_trig_rec                 IN     trig_rec_type,
     x_return_status            OUT NOCOPY    VARCHAR2
   )
IS
   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);
   l_additional_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
BEGIN
  --
  -- Initialize the OUT parameter
  --
  x_return_status := FND_API.g_ret_sts_success ;

-- Check arc_trigger_created_for
/*   IF p_trig_rec.arc_trigger_created_for <> FND_API.G_MISS_CHAR THEN
      IF p_trig_rec.arc_trigger_created_for <> 'CAMP'
      -- Commented by ptendulk on 14-Oct-2001 as Metric is not using triggers for refresh.
      -- AND p_trig_rec.arc_trigger_created_for <> 'AMET'
      THEN
         AMS_UTILITY_PVT.Error_Message('AMS_TRIG_INVALID_CREATED_FOR');
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- If any errors happen abort API/Procedure.
         RETURN;
      END IF;
   END IF;
*/
   l_table_name     := 'FND_TIMEZONES_VL';
   l_pk_name        := 'UPGRADE_TZ_ID' ;
   l_pk_data_type   := AMS_Utility_PVT.G_NUMBER ;
   l_pk_value       := p_trig_rec.timezone_id   ;

   IF p_trig_rec.timezone_id <> FND_API.G_MISS_NUM THEN
      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => null
         ) = FND_API.G_FALSE
      THEN
         AMS_UTILITY_PVT.Error_Message('AMS_TRIG_INVALID_TIMEZONE');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF ;

END Check_Trig_fk_Items ;

-- Start of Comments
--
-- NAME
--   Check_Trig_lookup_Items
--
-- PURPOSE
--   This procedure is to validate ams_triggers items
--    It will validates the lookup keys
-- NOTES
--
-- HISTORY
--   10/25/1999        ptendulk            created
-- End of Comments

PROCEDURE Check_Trig_Lookup_Items
( p_trig_rec                 IN     trig_rec_type,
  x_return_status            OUT NOCOPY    VARCHAR2
) IS
BEGIN
   --
   -- Initialize the OUT parameter
   --
   x_return_status := FND_API.g_ret_sts_success ;
   -- Check triggering_type
   IF p_trig_rec.triggering_type <> FND_API.G_MISS_CHAR
   THEN
      IF AMS_Utility_PVT.Check_Lookup_Exists
      ( p_lookup_table_name   => 'AMS_LOOKUPS'
       ,p_lookup_type          => 'AMS_TRIGGER_TYPE'
       ,p_lookup_code          => p_trig_rec.triggering_type
        ) = FND_API.G_FALSE
      THEN
         AMS_UTILITY_PVT.Error_Message('AMS_TRIG_INVALID_TRIGGER_TYPE');
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- If any errors happen abort API/Procedure.
         RETURN;
      END IF;
   END IF;

   -- Check repeat_frequency_type
   IF p_trig_rec.repeat_frequency_type <>  FND_API.G_MISS_CHAR
   AND p_trig_rec.repeat_frequency_type IS NOT NULL
   THEN
      IF AMS_Utility_PVT.Check_Lookup_Exists
      ( p_lookup_table_name   => 'AMS_LOOKUPS'
       ,p_lookup_type      => 'AMS_TRIGGER_FREQUENCY_TYPE'
       ,p_lookup_code      => p_trig_rec.repeat_frequency_type
       ) = FND_API.G_FALSE
      THEN
         AMS_UTILITY_PVT.Error_Message('AMS_TRIG_INVALID_FREQ_TYPE');
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- If any errors happen abort API/Procedure.
         RETURN;
      END IF;
   END IF;


END Check_Trig_Lookup_Items ;

-- Start of Comments
--
-- NAME
--   Check_Trig_Items
--
-- PURPOSE
--   This procedure is to validate ams_triggers items
-- NOTES
--
-- HISTORY
--   10/25/1999        ptendulk            created
-- End of Comments

PROCEDURE check_trig_items(
   p_trig_rec        IN  trig_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   Check_Trig_Req_Items(
      p_trig_rec       => p_trig_rec,
      x_return_status  => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
--dbms_output.put_line('After req : '||x_return_status);
   Check_Trig_UK_Items(
      p_trig_rec        => p_trig_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
--dbms_output.put_line('After uk : '||x_return_status);
   Check_Trig_Fk_Items(
      p_trig_rec       => p_trig_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
--dbms_output.put_line('After fk : '||x_return_status);
   Check_Trig_Lookup_Items(
      p_trig_rec        => p_trig_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Trig_Items;


-- Start of Comments
--
-- NAME
--   Find_End_Date
--
-- PURPOSE
--   This procedure is to find the End Date for the Activities
--
-- NOTES
--
--
-- HISTORY
--   02/26/2000        ptendulk            created
--   04/24/2000        ptendulk     Commented as its not being used
-- End of Comments
--PROCEDURE Find_End_Date
--                     (p_arc_act     IN    VARCHAR2,
--                      p_act_id      IN    NUMBER,
--                      x_dt          OUT   DATE)
--IS
--CURSOR c_camp IS
--   SELECT actual_exec_end_date
--   FROM   ams_campaigns_vl
--   WHERE  campaign_id = p_act_id ;
--
--CURSOR c_eveh IS
--   SELECT active_to_date
--   FROM   ams_event_headers_vl
--   WHERE  event_header_id = p_act_id ;
--
--CURSOR c_eveo IS
--   SELECT event_end_date
--   FROM   ams_event_offers_vl
--   WHERE  event_offer_id = p_act_id ;
--
--BEGIN
--   IF p_arc_act = 'CAMP' THEN
--       OPEN c_camp ;
--       FETCH c_camp INTO x_dt ;
--       CLOSE c_camp ;
--   ELSIF p_arc_act = 'EVEH' THEN
--       OPEN c_eveh ;
--       FETCH c_eveh INTO x_dt ;
--       CLOSE c_eveh ;
--   ELSIF p_arc_act = 'EVEO' THEN
--       OPEN c_eveo ;
--       FETCH c_eveo INTO x_dt ;
--       CLOSE c_eveo ;
--   END IF;
--END Find_End_Date;

-- Start of Comments
--
-- NAME
--   Validate_Trig_Record
--
-- PURPOSE
--   This procedure is to validate ams_triggers table.
--   This is an example if you need to call validation procedure from the UI site.
--
-- NOTES
--
--
-- HISTORY
--   07/26/1999        ptendulk     created
--   02/26/2000        ptendulk     Added Validation for the Trigger end Date
--   30-jul-2003       anchaudh     modified comparison operator to fix P1 bug# 3064909
--   21-aug-2003       soagrawa     Fixed bug 3108929
--   27-aug-2003       soagrawa     Fixed bug 3115141
-- End of Comments
PROCEDURE Check_Trig_Record(
   p_trig_rec       IN  trig_rec_type,
   p_complete_rec   IN  trig_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_start_date                DATE;
   l_end_date                  DATE;
   l_daily_start_time          DATE ;
   l_daily_end_time            DATE ;
   l_trigger_created_for       VARCHAR2(30);
   l_trigger_created_for_id    NUMBER ;

   l_table_name                VARCHAR2(30);
   l_pk_name                   VARCHAR2(30);
   l_pk_value                  VARCHAR2(30);
   l_pk_data_type              VARCHAR2(30);
   l_additional_where_clause   VARCHAR2(4000);  -- Used by Check_FK_Exists.

   l_repeat_freq               VARCHAR2(30);
   l_act_dt                    DATE;

   l_tz_end_date               DATE;
   l_msg_count                 NUMBER ;
   l_msg_data                  VARCHAR2(2000);

BEGIN
   --
   -- Initialize the Out Variable
   --
   x_return_status := FND_API.g_ret_sts_success;

      -- Check start date time
   IF (p_Trig_rec.user_repeat_stop_date_time IS NOT NULL AND
      p_Trig_rec.user_repeat_stop_date_time <> FND_API.G_MISS_DATE) OR
      p_trig_rec.user_start_date_time <> FND_API.G_MISS_DATE
   THEN
      IF p_trig_rec.user_start_date_time = FND_API.G_MISS_DATE THEN
           l_start_date := p_complete_rec.user_start_date_time;
      ELSE
           l_start_date := p_trig_rec.user_start_date_time;
      END IF ;
      IF p_trig_rec.user_repeat_stop_date_time = FND_API.G_MISS_DATE THEN
           l_end_date := p_complete_rec.user_repeat_stop_date_time ;
      ELSE
           l_end_date := p_trig_rec.user_repeat_stop_date_time ;
      END IF ;
--    Following code is added by ptendulk on 26Feb2000
--           IF p_trig_rec.trigger_created_for_id = FND_API.G_MISS_NUM THEN
--      l_trigger_created_for_id  := p_complete_rec.trigger_created_for_id ;
--     ELSE
--         l_trigger_created_for_id  := p_trig_rec.trigger_created_for_id ;
--     END IF;
--
--     IF p_trig_rec.arc_trigger_created_for = FND_API.G_MISS_CHAR THEN
--         l_trigger_created_for := p_complete_rec.arc_trigger_created_for ;
--     ELSE
--         l_trigger_created_for := p_trig_rec.arc_trigger_created_for ;
--     END IF;
--
     IF l_end_date IS NOT NULL THEN
         IF l_start_date >  l_end_date  THEN
         -- invalid item
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_DT_RANGE');
                FND_MSG_PUB.Add;
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
         END IF;

    --following code is added by cgoyal for bugfix#3055863
      -- anchaudh modified operator to fix P1 bug# 3064909
    IF p_trig_rec.trigger_id IS NULL -- soagrawa added this on 21-aug-2003 for bug# 3108929, check only for create
    THEN
       -- soagrawa added time zone conversion on 27-aug-2003 for bug# 3115141

       AMS_UTILITY_PVT.Convert_Timezone(
                   p_init_msg_list   => FND_API.G_FALSE ,
                   x_return_status   => x_return_status ,
                   x_msg_count       => l_msg_count   ,
                   x_msg_data        => l_msg_data   ,
                   p_user_tz_id      => p_trig_rec.timezone_id   ,  -- required
                   p_in_time         => l_end_date   ,                  -- required
                   x_out_time        => l_tz_end_date
       );

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       -- end soagrawa for bug# 3115141

       IF l_tz_end_date < SYSDATE THEN
       -- IF l_end_date < SYSDATE THEN
       -- IF l_end_date > SYSDATE THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_END_DT');
                FND_MSG_PUB.Add;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
       END IF;
    END IF;

      -- Following code is commented by ptendulk on 26th apr
      -- as trigger can fire after the campaign is expired
--    Following code is added by ptendulk on 26Feb2000
              --
              -- Get the end Date for the Activity
              --
--              Find_End_Date( p_arc_act     =>  l_trigger_created_for,
--                             p_act_id      =>  l_trigger_created_for_id,
--                             x_dt          =>  l_act_dt )  ;

--              IF l_act_dt <  l_end_date  THEN
--         -- invalid item
--           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
--           THEN -- MMSG
----               DBMS_OUTPUT.Put_Line('Start Date time or End Date Time is invalid');
--         FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_DT_RANGE');
--                FND_MSG_PUB.Add;
--            END IF;
--       x_return_status := FND_API.G_RET_STS_ERROR;
--       -- If any errors happen abort API/Procedure.
--       RETURN;
--              END IF;

      END IF;
   END IF;
--dbms_output.put_line('After Date Check : '||x_return_status);
   -- Check Repeat daily start time
   IF (p_trig_rec.user_repeat_daily_start_time <> FND_API.G_MISS_DATE  AND
      p_trig_rec.user_repeat_daily_start_time IS NOT NULL     )   OR
      (p_trig_rec.user_repeat_daily_end_time   <> FND_API.G_MISS_DATE  AND
       p_trig_rec.user_repeat_daily_end_time   IS NOT NULL )
   THEN
     IF p_trig_rec.user_repeat_daily_start_time = FND_API.G_MISS_DATE THEN
         l_daily_start_time := p_complete_rec.user_repeat_daily_start_time;
     ELSE
         l_daily_start_time := p_trig_rec.user_repeat_daily_start_time;
     END IF;

     IF p_trig_rec.user_repeat_daily_end_time = FND_API.G_MISS_DATE THEN
         l_daily_end_time := p_complete_rec.user_repeat_daily_end_time;
     ELSE
         l_daily_end_time := p_trig_rec.user_repeat_daily_end_time;
     END IF;

     IF (l_daily_start_time IS NULL AND l_daily_end_time IS NOT NULL )
     OR (l_daily_start_time IS NOT NULL AND l_daily_end_time IS NULL )
     THEN
        AMS_UTILITY_PVT.Error_Message('AMS_TRIG_MISSING_RPT_DAILY_TM');
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- If any errors happen abort API/Procedure.
        RETURN;
     ELSIF l_daily_start_time >  l_daily_end_time
     THEN
         AMS_UTILITY_PVT.Error_Message('AMS_TRIG_INVALID_DAILY_RANGE');
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- If any errors happen abort API/Procedure.
         RETURN;
      END IF;
   END IF;

--dbms_output.put_line('After time check : '||x_return_status);
   IF p_trig_rec.arc_trigger_created_for <> FND_API.G_MISS_CHAR
   OR p_trig_rec.trigger_created_for_id <> FND_API.G_MISS_NUM THEN

     IF p_trig_rec.trigger_created_for_id = FND_API.G_MISS_NUM THEN
         l_trigger_created_for_id  := p_complete_rec.trigger_created_for_id ;
     ELSE
         l_trigger_created_for_id  := p_trig_rec.trigger_created_for_id ;
     END IF;

     IF p_trig_rec.arc_trigger_created_for = FND_API.G_MISS_CHAR THEN
         l_trigger_created_for := p_complete_rec.arc_trigger_created_for ;
     ELSE
         l_trigger_created_for := p_trig_rec.arc_trigger_created_for ;
     END IF;


     -- Get table_name and pk_name for the ARC qualifier.
      AMS_Utility_PVT.Get_Qual_Table_Name_And_PK (
         p_sys_qual                     => l_trigger_created_for,
         x_return_status                => x_return_status,
         x_table_name                   => l_table_name,
         x_pk_name                      => l_pk_name
      );

      l_pk_value                 := l_trigger_created_for_id;
      l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      l_additional_where_clause  := NULL;
--dbms_output.put_line('Tab name : '||l_table_name);
--dbms_output.put_line('pk name : '||l_pk_name);
/*      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => l_table_name
            ,p_pk_name                      => l_pk_name
            ,p_pk_value                     => l_pk_value
            ,p_pk_data_type                 => l_pk_data_type
            ,p_additional_where_clause      => l_additional_where_clause
         ) = FND_API.G_FALSE
      THEN
         AMS_UTILITY_PVT.Error_Message('AMS_TRIG_INVALID_CREATED_FOR');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
  */
  END IF;
--dbms_output.put_line('After Camp Chk : '||x_return_status);
   -- Repeat Every X Frequency
   IF p_trig_rec.repeat_frequency_type <> FND_API.G_MISS_CHAR THEN

     IF p_trig_rec.repeat_every_x_frequency = FND_API.G_MISS_NUM THEN
         l_repeat_freq  := p_complete_rec.repeat_every_x_frequency ;
     ELSE
         l_repeat_freq  := p_trig_rec.repeat_every_x_frequency ;
     END IF;

     IF p_trig_rec.repeat_frequency_type <> 'NONE'                  AND
        l_repeat_freq IS NULL
     THEN
         AMS_UTILITY_PVT.Error_Message('AMS_TRIG_MISSING_EVERY_X_FREQ');
         x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
     END IF;
   END IF;

END Check_Trig_Record;

-- Start of Comments
--
-- NAME
--   Init_Trig_Rec
--
-- PURPOSE
--   This procedure is to Initialize the Record type before Updation.
--
-- NOTES
--
--
-- HISTORY
--   10/26/1999        ptendulk            created
--   22/apr/03         cgoyal              added notify_flag and execute_schedule_flag
-- End of Comments
PROCEDURE Init_Trig_Rec(
   x_trig_rec  OUT NOCOPY  trig_rec_type
)
IS
BEGIN
  x_trig_rec.trigger_id                :=   FND_API.G_MISS_NUM  ;
  x_trig_rec.last_update_date               :=   FND_API.G_MISS_DATE ;
  x_trig_rec.last_updated_by                :=   FND_API.G_MISS_NUM  ;
  x_trig_rec.creation_date                  :=   FND_API.G_MISS_DATE ;
  x_trig_rec.created_by                     :=   FND_API.G_MISS_NUM  ;
  x_trig_rec.last_update_login              :=   FND_API.G_MISS_NUM  ;
  x_trig_rec.object_version_number          :=   FND_API.G_MISS_NUM  ;
  x_trig_rec.process_id                     :=   FND_API.G_MISS_NUM  ;
  x_trig_rec.trigger_created_for_id         :=   FND_API.G_MISS_NUM  ;
  x_trig_rec.arc_trigger_created_for        :=   FND_API.G_MISS_CHAR ;
  x_trig_rec.triggering_type                :=   FND_API.G_MISS_CHAR ;
  x_trig_rec.trigger_name                   :=   FND_API.G_MISS_CHAR ;
  x_trig_rec.view_application_id            :=   FND_API.G_MISS_NUM  ;
  x_trig_rec.timezone_id                    :=  FND_API.G_MISS_NUM  ;
  x_trig_rec.user_start_date_time           :=   FND_API.G_MISS_DATE ;
  x_trig_rec.start_date_time                :=   FND_API.G_MISS_DATE ;
  x_trig_rec.user_last_run_date_time        :=   FND_API.G_MISS_DATE ;
  x_trig_rec.last_run_date_time             :=   FND_API.G_MISS_DATE ;
  x_trig_rec.user_next_run_date_time        :=   FND_API.G_MISS_DATE ;
  x_trig_rec.next_run_date_time             :=   FND_API.G_MISS_DATE ;
  x_trig_rec.user_repeat_daily_start_time   :=   FND_API.G_MISS_DATE ;
  x_trig_rec.repeat_daily_start_time        :=   FND_API.G_MISS_DATE ;
  x_trig_rec.user_repeat_daily_end_time     :=   FND_API.G_MISS_DATE ;
  x_trig_rec.repeat_daily_end_time          :=   FND_API.G_MISS_DATE ;
  x_trig_rec.repeat_frequency_type          :=   FND_API.G_MISS_CHAR ;
  x_trig_rec.repeat_every_x_frequency       :=   FND_API.G_MISS_NUM  ;
  x_trig_rec.user_repeat_stop_date_time     :=   FND_API.G_MISS_DATE ;
  x_trig_rec.repeat_stop_date_time          :=   FND_API.G_MISS_DATE ;
  x_trig_rec.metrics_refresh_type           :=   FND_API.G_MISS_CHAR ;
  x_trig_rec.description                    :=   FND_API.G_MISS_CHAR ;
  x_trig_rec.notify_flag                    :=   FND_API.G_MISS_CHAR ;
  x_trig_rec.execute_schedule_flag          :=   FND_API.G_MISS_CHAR ;
  x_trig_rec.TRIGGERED_STATUS               :=   FND_API.G_MISS_CHAR ;-- anchaudh added for R12 monitors.
  x_trig_rec.USAGE                          :=   FND_API.G_MISS_CHAR ;-- anchaudh added for R12 monitors.
END Init_Trig_Rec ;

-- Start of Comments
--
-- NAME
--   Complete_Trig_rec
--
-- PURPOSE
--   This procedure is to complete the Rec type sent before Update
--
-- NOTES
--
--
-- HISTORY
--   10/26/1999        ptendulk            created
--   22-apr-03	      cgoyal added         NOTIFY_FLAG, EXECUTE_SCHEDULE_FLAG column defaulting
-- End of Comments

PROCEDURE Complete_Trig_Rec(
   p_trig_rec      IN  trig_rec_type,
   x_complete_rec  OUT NOCOPY trig_rec_type
)
IS

   CURSOR c_trig IS
   SELECT *
     FROM ams_triggers_vl
    WHERE trigger_id = p_trig_rec.trigger_id;

   l_trig_rec  c_trig%ROWTYPE;

BEGIN

   x_complete_rec := p_trig_rec;

   OPEN c_trig;
   FETCH c_trig INTO l_trig_rec;
   IF c_trig%NOTFOUND THEN
      CLOSE c_trig;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_trig;

   IF p_trig_rec.process_id = FND_API.G_MISS_NUM THEN
      x_complete_rec.process_id := l_trig_rec.process_id;
   END IF;

   IF p_trig_rec.trigger_created_for_id = FND_API.G_MISS_NUM THEN
      x_complete_rec.trigger_created_for_id := l_trig_rec.trigger_created_for_id;
   END IF;

   IF p_trig_rec.arc_trigger_created_for = FND_API.G_MISS_CHAR THEN
      x_complete_rec.arc_trigger_created_for  := l_trig_rec.arc_trigger_created_for ;
   END IF;

   IF p_trig_rec.triggering_type = FND_API.G_MISS_CHAR THEN
      x_complete_rec.triggering_type  := l_trig_rec.triggering_type ;
   END IF;

   IF p_trig_rec.trigger_name = FND_API.G_MISS_CHAR THEN
      x_complete_rec.trigger_name  := l_trig_rec.trigger_name ;
   END IF;

   IF p_trig_rec.view_application_id = FND_API.G_MISS_NUM THEN
      x_complete_rec.view_application_id := l_trig_rec.view_application_id ;
   END IF;

   IF p_trig_rec.timezone_id = FND_API.G_MISS_NUM THEN
      x_complete_rec.timezone_id := l_trig_rec.timezone_id ;
   END IF;

   IF p_trig_rec.user_start_date_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.user_start_date_time := l_trig_rec.user_start_date_time ;
   END IF;

   IF p_trig_rec.start_date_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.start_date_time := l_trig_rec.start_date_time ;
   END IF;

   IF p_trig_rec.user_last_run_date_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.user_last_run_date_time := l_trig_rec.user_last_run_date_time ;
   END IF;

   IF p_trig_rec.last_run_date_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.last_run_date_time := l_trig_rec.last_run_date_time ;
   END IF;

   IF p_trig_rec.user_next_run_date_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.user_next_run_date_time := l_trig_rec.user_next_run_date_time ;
   END IF;

   IF p_trig_rec.next_run_date_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.next_run_date_time := l_trig_rec.next_run_date_time ;
   END IF;

   IF p_trig_rec.user_repeat_daily_start_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.user_repeat_daily_start_time  := l_trig_rec.user_repeat_daily_start_time  ;
   END IF;

   IF p_trig_rec.repeat_daily_start_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.repeat_daily_start_time := l_trig_rec.repeat_daily_start_time ;
   END IF;

   IF p_trig_rec.user_repeat_daily_end_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.user_repeat_daily_end_time := l_trig_rec.user_repeat_daily_end_time ;
   END IF;

   IF p_trig_rec.repeat_daily_end_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.repeat_daily_end_time := l_trig_rec.repeat_daily_end_time ;
   END IF;

   IF p_trig_rec.repeat_frequency_type = FND_API.G_MISS_CHAR THEN
      x_complete_rec.repeat_frequency_type := l_trig_rec.repeat_frequency_type ;
   END IF;

   IF p_trig_rec.repeat_every_x_frequency = FND_API.G_MISS_NUM THEN
      x_complete_rec.repeat_every_x_frequency := l_trig_rec.repeat_every_x_frequency;
   END IF;

   IF p_trig_rec.repeat_stop_date_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.repeat_stop_date_time := l_trig_rec.repeat_stop_date_time ;
   END IF;

   IF p_trig_rec.user_repeat_stop_date_time = FND_API.G_MISS_DATE THEN
      x_complete_rec.user_repeat_stop_date_time := l_trig_rec.user_repeat_stop_date_time ;
   END IF;



   IF p_trig_rec.metrics_refresh_type = FND_API.G_MISS_CHAR THEN
      x_complete_rec.metrics_refresh_type := l_trig_rec.metrics_refresh_type ;
   END IF;

   IF p_trig_rec.description     = FND_API.G_MISS_CHAR THEN
      x_complete_rec.description := l_trig_rec.description ;
   END IF;

-- CGOYAL added for 11.5.8 backport
   IF p_trig_rec.NOTIFY_FLAG     = FND_API.G_MISS_CHAR THEN
      x_complete_rec.NOTIFY_FLAG := l_trig_rec.NOTIFY_FLAG ;
   END IF;

   IF p_trig_rec.EXECUTE_SCHEDULE_FLAG     = FND_API.G_MISS_CHAR THEN
      x_complete_rec.EXECUTE_SCHEDULE_FLAG := l_trig_rec.EXECUTE_SCHEDULE_FLAG ;
   END IF;

   -- anchaudh added for R12 monitors.
   IF p_trig_rec.TRIGGERED_STATUS     = FND_API.G_MISS_CHAR THEN
      x_complete_rec.TRIGGERED_STATUS := l_trig_rec.TRIGGERED_STATUS ;
   END IF;

   IF p_trig_rec.USAGE     = FND_API.G_MISS_CHAR THEN
      x_complete_rec.USAGE := l_trig_rec.USAGE ;
   END IF;
--

END Complete_Trig_Rec ;

END AMS_Trig_PVT;

/
