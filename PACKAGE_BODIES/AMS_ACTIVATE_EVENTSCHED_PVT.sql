--------------------------------------------------------
--  DDL for Package Body AMS_ACTIVATE_EVENTSCHED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTIVATE_EVENTSCHED_PVT" AS
/* $Header: amsvevcb.pls 120.6 2006/05/11 01:25:31 batoleti ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='AMS_Activate_EventSched_PVT';



--========================================================================
-- PROCEDURE
--    Activate_Schedule
--
-- PURPOSE
--    This api is created to activate available event schedules.
--
-- Note
--    This procedure will be called by concurrent program to activate the
--    event shedules which are in available state and whose Registration
--    start date is equal to the sys date and to complete the event
--    whose event_end_date is equal to the sys date.
--
-- HISTORY
--  07-Jan-2002    gmadana created.
--========================================================================
PROCEDURE Activate_Schedule
(
      p_api_version             IN     NUMBER,
      p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
      p_commit                  IN     VARCHAR2 := FND_API.G_False,

      x_return_status           OUT NOCOPY    VARCHAR2,
      x_msg_count               OUT NOCOPY    NUMBER  ,
      x_msg_data                OUT NOCOPY    VARCHAR2
 )
IS

   CURSOR c_all_schedule IS
   SELECT offr.event_offer_id, offr.object_version_number,offr.event_level,offr.parent_id
   FROM   ams_event_offers_all_b offr, ams_event_headers_all_b hdr
   WHERE  offr.system_status_code = 'AVAILABLE'
   --AND    offr.reg_required_flag = 'Y'
   --AND    offr.reg_start_date <= SYSDATE
   AND    offr.event_header_id = hdr.event_header_id
   AND    hdr.system_status_code = 'ACTIVE';
--   AND    offr.event_offer_id  in (10136,10147);

   CURSOR c_all_oneoffevent IS
   SELECT event_offer_id, object_version_number, parent_id,event_level
   FROM   ams_event_offers_all_b
   WHERE  system_status_code = 'AVAILABLE'
   --AND    reg_required_flag = 'Y'
   --AND    reg_start_date <= SYSDATE
   AND    event_header_id IS NULL
   AND    nvl(parent_type, 'RCAM') <> 'CAMP';
--   AND    event_offer_id = 10134;


  /* CURSOR c_completed_schedule IS
   SELECT event_offer_id, object_version_number,event_level
   FROM   ams_event_offers_all_b
   WHERE  system_status_code = 'ACTIVE'
   AND    event_end_date <= SYSDATE
   AND    nvl(parent_type, 'RCAM') <> 'CAMP';*/
--   AND    event_offer_id = 10134;

   --Added for timeZOne issue FIX :  BUG 4482556 ANSKUMAR

  --Will convert the sysdate to the user timezone
    CURSOR c_completed_schedule_convdate(l_conv_sysdate DATE) IS
   SELECT event_offer_id, object_version_number,event_level
   FROM   ams_event_offers_all_b
   WHERE  system_status_code = 'ACTIVE'
   AND    event_end_date <= l_conv_sysdate
   AND    nvl(parent_type, 'RCAM') <> 'CAMP';
   --End Adding

   CURSOR c_status(l_status_code VARCHAR2) IS
   SELECT user_status_id
   FROM   ams_user_statuses_b
   WHERE  system_status_type = 'AMS_EVENT_STATUS'
   AND    system_status_code = l_status_code
   AND    default_flag = 'Y'
   AND    enabled_flag = 'Y' ;

   /* Cursor to get the user status id of  program */
   CURSOR c_PROGRAM_status (l_event_offer_id IN NUMBER) IS
   SELECT user_status_id
   FROM   ams_campaigns_all_b
   WHERE  campaign_id = l_event_offer_id;
  -- added for time zone issue Fix :  BUG 4482556 ANSKUMAR
   l_system_d_time         DATE;
   l_sys_start_time        DATE;
   l_user_timezone_id      NUMBER;
   l_return_status	   VARCHAR2(1);
   l_msg_count		   NUMBER;
   l_msg_data		  VARCHAR2(2000);
  --End Adding

   l_status_id             NUMBER ;
   l_schedule_id           NUMBER ;
   l_header_id             NUMBER;
   l_obj_version           NUMBER ;
   l_program_id            NUMBER;
   l_parent_id             NUMBER;
   l_parent_status_id      NUMBER;
   l_parent_system_status_code  VARCHAR2(30);
   l_event_level  VARCHAR2(30);
   l_return_flag  VARCHAR2(30);

   l_api_version   CONSTANT NUMBER := 1.0 ;
   l_api_name      CONSTANT VARCHAR2(30)  := 'Activate_Event_Schedule';

   l_evo_rec      AMS_EVENTOFFER_PVT.evo_rec_type;
   l_evo_rec_oneoff   AMS_EVENTOFFER_PVT.evo_rec_type;
   l_evo_rec_eveo      AMS_EVENTOFFER_PVT.evo_rec_type;

BEGIN
   --
   -- Standard Start of API savepoint
   --
   --Added for TimeZOne Issue Fix
      l_system_d_time:=SYSDATE;
   --End Adding

   SAVEPOINT AMS_ACTIVATE_SCHEDULE;

   --
   -- Debug Message
   --
   AMS_Utility_PVT.debug_message(l_api_name || ': start');

   --
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call ( 1.0,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   l_return_flag := 'Y';


   OPEN c_status('ACTIVE') ;
   FETCH c_status INTO l_status_id ;
   IF c_status%NOTFOUND THEN
      CLOSE c_status;
      AMS_Utility_PVT.error_message('AMS_EVENT_BAD_USER_STATUS');
      RETURN ;
   END IF ;
   CLOSE c_status ;

   /* Making all Event Schedules which are in available status to
      Active status, if their enrollment start date is equal to sysdate
      and their parent(EVEH) is active.
    */
   OPEN c_all_schedule ;
   LOOP

   BEGIN
      SAVEPOINT C_ALL_SCHEDULE;

      FETCH c_all_schedule INTO l_schedule_id, l_obj_version,l_event_level,l_parent_id ;
      EXIT WHEN c_all_schedule%NOTFOUND ;

      -- Update the status of the schedule to Active.
     /* UPDATE ams_event_offers_all_b
      SET system_status_code = 'ACTIVE',
        last_status_date = SYSDATE ,
        user_status_id     = l_status_id,
        object_version_number = l_obj_version + 1
      WHERE  event_offer_id = l_schedule_id ;*/

      /* l_parent_system_status_code := '';
      IF l_parent_id IS NOT NULL THEN
          -- A NEW CURSOR NEEDS TO BE THERE FOR THIS BELOW.: ANCHAUDH
         OPEN c_EVENT_status(l_parent_id);
         FETCH c_EVENT_status INTO l_parent_status_id;
         CLOSE c_EVENT_status;

        -- Getting the system_status_code of Parent
        l_parent_system_status_code := Ams_Utility_Pvt.get_system_status_code(l_parent_status_id);

      END IF;

      IF l_parent_system_status_code = 'ACTIVE'  THEN*/

      AMS_EVENTOFFER_PVT.init_evo_rec(l_evo_rec_eveo);
        l_evo_rec_eveo.event_offer_id := l_schedule_id;
        l_evo_rec_eveo.object_version_number := l_obj_version;
        l_evo_rec_eveo.system_status_code := 'ACTIVE';
        l_evo_rec_eveo.last_status_date := SYSDATE;
        l_evo_rec_eveo.user_status_id := l_status_id;
	l_evo_rec_eveo.event_level := l_event_level;

	 AMS_EventOffer_PVT.update_event_offer (
         p_api_version  => 1.0,
         p_init_msg_list   => FND_API.G_FALSE,
         p_commit          => FND_API.G_FALSE,
         p_validation_level   =>  FND_API.g_valid_level_full,

         p_evo_rec       => l_evo_rec_eveo,

         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           l_return_flag := 'N';
           ROLLBACK TO C_ALL_SCHEDULE;
        END IF;

	COMMIT;

	EXCEPTION
	 WHEN OTHERS THEN
          l_return_flag := 'N';
	  x_return_status := FND_API.g_ret_sts_error;
         ROLLBACK TO C_ALL_SCHEDULE;

      END;


     -- END IF;

   END LOOP;
   CLOSE c_all_schedule ;

   /* Making all OneoffEvents which are in available status to
      Active status, if their enrollment start date is equal to sysdate
      and their parent(PROGRAM) is active.
   */
   OPEN c_all_oneoffevent ;
   LOOP

   BEGIN
      SAVEPOINT C_ALL_ONEOFFEVENT;

      FETCH c_all_oneoffevent INTO l_schedule_id, l_obj_version, l_parent_id, l_event_level ;
      EXIT WHEN c_all_oneoffevent%NOTFOUND ;

      l_parent_system_status_code := '';
      IF l_parent_id IS NOT NULL THEN

         OPEN c_PROGRAM_status(l_parent_id);
         FETCH c_PROGRAM_status INTO l_parent_status_id;
         CLOSE c_PROGRAM_status;

        /* Getting the system_status_code of Parent */
        l_parent_system_status_code := Ams_Utility_Pvt.get_system_status_code(l_parent_status_id);

      END IF;

      IF l_parent_system_status_code = 'ACTIVE' OR l_parent_id IS NULL THEN

         -- Update the status of the oneoffevent to Active.
       /*  UPDATE ams_event_offers_all_b
         SET system_status_code = 'ACTIVE',
           last_status_date = SYSDATE ,
           user_status_id     = l_status_id,
           object_version_number = l_obj_version + 1
         WHERE  event_offer_id = l_schedule_id ;*/

       AMS_EVENTOFFER_PVT.init_evo_rec(l_evo_rec_oneoff);
        l_evo_rec_oneoff.event_offer_id := l_schedule_id;
        l_evo_rec_oneoff.object_version_number := l_obj_version;
        l_evo_rec_oneoff.system_status_code := 'ACTIVE';
        l_evo_rec_oneoff.last_status_date := SYSDATE;
        l_evo_rec_oneoff.user_status_id := l_status_id;
	--batoleti  changed the foll stmt.. Ref bug# 4404567.
	--l_evo_rec_oneoff.user_status_id := l_event_level;
	l_evo_rec_oneoff.event_level := l_event_level;

	 AMS_EventOffer_PVT.update_event_offer (
         p_api_version  => 1.0,
         p_init_msg_list   => FND_API.G_FALSE,
         p_commit          => FND_API.G_FALSE,
         p_validation_level   =>  FND_API.g_valid_level_full,

         p_evo_rec       => l_evo_rec_oneoff,

         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data
        );

       END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           l_return_flag := 'N';
           ROLLBACK TO C_ALL_ONEOFFEVENT;
        END IF;

      COMMIT;

      EXCEPTION
       WHEN OTHERS THEN
          l_return_flag := 'N';
	  x_return_status := FND_API.g_ret_sts_error;
	ROLLBACK TO C_ALL_ONEOFFEVENT;

   END;

   END LOOP;
   CLOSE c_all_oneoffevent ;


    -- Change the status of all the schedules which are active to
    -- completed.
    OPEN c_status('COMPLETED') ;
      FETCH c_status INTO l_status_id ;
      IF c_status%NOTFOUND THEN
         CLOSE c_status;
         AMS_Utility_PVT.error_message('AMS_EVENT_BAD_USER_STATUS');
         RETURN ;
      END IF ;
    CLOSE c_status ;

  --Added for time Zone issue FIX :  BUG 4482556 ANSKUMAR
       l_user_timezone_id:= FND_PROFILE.VALUE('CLIENT_TIMEZONE_ID');
       --API to convert the sysdate to usertimezone Date :  BUG 4482556 ANSKUMAR
       AMS_UTILITY_PVT.Convert_Timezone(
                     p_init_msg_list   => FND_API.G_TRUE,
                     x_return_status   => l_return_status,
                     x_msg_count       => l_msg_count,
                     x_msg_data        => l_msg_data,

                     p_user_tz_id      => l_user_timezone_id,
                     p_in_time         => l_system_d_time,
                     p_convert_type    => 'USER',

                     x_out_time        => l_sys_start_time
                     );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  l_sys_start_time := SYSDATE;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  l_sys_start_time := SYSDATE;
              END IF;

  --End Adding

   -- OPEN c_completed_schedule ;
     OPEN c_completed_schedule_convdate(l_sys_start_time);
      LOOP

      BEGIN
         SAVEPOINT C_COMPLETED_SCHEDULE;
    --These lines are comented  and adde new for  BUG 4482556 ANSKUMAR
    --     FETCH c_completed_schedule INTO l_schedule_id, l_obj_version,l_event_level ;
    --     EXIT WHEN c_completed_schedule%NOTFOUND ;
         FETCH c_completed_schedule_convdate INTO l_schedule_id, l_obj_version,l_event_level ;
         EXIT WHEN c_completed_schedule_convdate%NOTFOUND ;

      AMS_EVENTOFFER_PVT.init_evo_rec( l_evo_rec);
        l_evo_rec.event_offer_id := l_schedule_id;
        l_evo_rec.object_version_number := l_obj_version ;
        l_evo_rec.system_status_code := 'COMPLETED';
        l_evo_rec.last_status_date := SYSDATE;
        l_evo_rec.user_status_id := l_status_id;
        l_evo_rec.event_level := l_event_level;

       AMS_EventOffer_PVT.update_event_offer (
         p_api_version  => 1.0,
         p_init_msg_list   => FND_API.G_FALSE,
         p_commit          => FND_API.G_FALSE,
         p_validation_level   =>  FND_API.g_valid_level_full,

         p_evo_rec       => l_evo_rec,

         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data
        );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           l_return_flag := 'N';
           ROLLBACK TO C_COMPLETED_SCHEDULE;
       END IF;

       COMMIT;

	EXCEPTION
	 WHEN OTHERS THEN
          l_return_flag := 'N';
	  x_return_status := FND_API.g_ret_sts_error;
         ROLLBACK TO C_COMPLETED_SCHEDULE;

       END;

        /*IF x_return_status = FND_API.g_ret_sts_error THEN
		      RAISE FND_API.g_exc_error;
	     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
	      	RAISE FND_API.g_exc_unexpected_error;
	     END IF;*/

      END LOOP;
   -- CLOSE c_completed_schedule;
      CLOSE c_completed_schedule_convdate;
   --
   -- Standard check of p_commit.
   --
   IF FND_API.To_Boolean ( p_commit )
   THEN
        COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
   FND_MSG_PUB.Count_AND_Get
     ( p_count       =>      x_msg_count,
       p_data        =>      x_msg_data,
       p_encoded 	=>      FND_API.G_FALSE
      );

   AMS_Utility_PVT.debug_message(l_api_name ||' : end Status : ' || x_return_status);
   --dbms_output.put_line(l_api_name ||' : end Status : ' || x_return_status);

   IF (l_return_flag = 'Y') THEN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
   ELSE
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

       IF (c_all_schedule%ISOPEN) THEN
          CLOSE c_all_schedule ;
       END IF;
       ROLLBACK TO AMS_ACTIVATE_SCHEDULE;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_AND_Get
       ( p_count       =>      x_msg_count,
         p_data        =>      x_msg_data,
         p_encoded    	=>      FND_API.G_FALSE
       );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF (c_all_schedule%ISOPEN) THEN
          CLOSE c_all_schedule ;
       END IF;
       ROLLBACK TO AMS_ACTIVATE_SCHEDULE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_AND_Get
       ( p_count       =>      x_msg_count,
         p_data        =>      x_msg_data,
         p_encoded    	=>      FND_API.G_FALSE
       );

   WHEN OTHERS THEN
       IF (c_all_schedule%ISOPEN) THEN
          CLOSE c_all_schedule ;
       END IF;
       ROLLBACK TO AMS_ACTIVATE_SCHEDULE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
       THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

       FND_MSG_PUB.Count_AND_Get
                ( p_count       =>      x_msg_count,
                  p_data        =>      x_msg_data,
                  p_encoded    	=>      FND_API.G_FALSE
                );


END Activate_Schedule ;

--========================================================================
-- PROCEDURE
--    Activate_Schedule
--
-- PURPOSE
--    This api is created to be used by concurrent program to activate
--    schedules. It will internally call the Activate schedules api to
--    activate the schedule.

--
-- HISTORY
--  08-Jan-2001    gmadana    Created.
--
--========================================================================
PROCEDURE Activate_Schedule
               (errbuf            OUT NOCOPY    VARCHAR2,
                retcode           OUT NOCOPY    VARCHAR2)
IS
   l_return_status    VARCHAR2(1) ;
   l_msg_count        NUMBER ;
   l_msg_data         VARCHAR2(2000);
   l_api_version      NUMBER := 1.0 ;
BEGIN
   FND_MSG_PUB.initialize;

   /*AMS_Activate_EventSched_PVT.Activate_Schedule(
         p_api_version             => l_api_version ,

         x_return_status           => l_return_status,
         x_msg_count               => l_msg_count,
         x_msg_data                => l_msg_data
   ) ;*/

  AMS_Activate_EventSched_PVT.Activate_Schedule(
      p_api_version      => l_api_version,
      p_init_msg_list    => FND_API.G_False,
      p_commit          =>   FND_API.G_False,

      x_return_status     => l_return_status,
      x_msg_count     => l_msg_count ,
      x_msg_data      => l_msg_data
 );

   -- Write_log ;
   Ams_Utility_Pvt.Write_Conc_log ;

   IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
      retcode :=0;
   ELSE
      retcode  := 2;
      errbuf   :=  l_msg_data ;
   END IF;
END Activate_Schedule;


END Ams_Activate_Eventsched_Pvt ;

/
