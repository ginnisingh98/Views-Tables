--------------------------------------------------------
--  DDL for Package Body AMS_TRACKING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TRACKING_PVT" as
/* $Header: amsvtrkb.pls 120.1 2006/10/27 23:35:17 rrajesh noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TRACKING_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_TRACKING_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvtrkb.pls';

FUNCTION isMinisite_iStore(p_minisite_id IN NUMBER) RETURN BOOLEAN
IS
l_count NUMBER := 0;
BEGIN
     SELECT COUNT(MSITE_ID) into l_count FROM IBE_MSITES_B where MSITE_ID = p_minisite_id;
      IF l_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END isMinisite_iStore;


/* PROCEDURE insert_log_mesg (p_mesg IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 insert into raghu_table values (p_mesg, sysdate);
 commit;
END; */


PROCEDURE Log_interaction(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_interaction_id      OUT NOCOPY NUMBER,

    p_track_rec           IN  interaction_track_rec_type := g_miss_ps_strats_rec
    )
 IS
   L_API_NAME               CONSTANT VARCHAR2(30) := 'Log_interaction';
   L_API_VERSION_NUMBER     CONSTANT NUMBER   := 1.0;

   l_interaction_rec    JTF_IH_PUB.interaction_rec_type;
   l_media_rec          JTF_IH_PUB.media_rec_type;
   l_activity_rec       JTF_IH_PUB.activity_rec_type;
   l_activity_tbl       JTF_IH_PUB.activity_tbl_type;
   l_media_id           NUMBER;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_resource_id        NUMBER;
   l_interaction_id     NUMBER := null;
   code_id              NUMBER := null;
   l_activity_id        NUMBER;
   l_action_item_id     NUMBER;
   l_minisite_id  NUMBER := null;
   l_web_content_id NUMBER := null;
   l_activity_type      VARCHAR2(30);
   obj_type VARCHAR2(4);

  CURSOR c_minisite_id(p_webcontent_id NUMBER) IS
    SELECT NVL(display_rule_id,0) FROM jtf_amv_attachments WHERE
    attachment_id = p_webcontent_id;

  CURSOR c_minisite_id_lite(p_webcontent_id NUMBER) IS
    select p.action_param_value
    from ams_ctds a, ams_ctd_param_values p
    where a.ctd_id = p.ctd_id
    and p.action_param_id in (21,31,41, 61)
    and a.ctd_id = p_webcontent_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Log_interaction ;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- JTF_IH_PUB.open_mediaitem
      l_media_rec.start_date_time  := SYSDATE;

--   IF (p_track_rec.obj_type = 'CSCH')
--      THEN
        l_media_rec.media_item_type := 'WEB FORM';
--      ELSE
--        l_media_rec.media_item_type     := 'WEB FORM';

--     Keeping it as WEB FORM for the time being,will change shortly.

--      END IF;

-- Validation for Minisite and Populate the media_rec
-- Validate for PHAT ONLY

    IF (p_track_rec.web_content_id IS NOT NULL ) THEN
        l_web_content_id := p_track_rec.web_content_id;
        l_media_rec.source_id := l_web_content_id;

        IF (p_track_rec.flavour <> 'LITE') THEN
          OPEN c_minisite_id(l_web_content_id);
          FETCH c_minisite_id INTO l_minisite_id;
          CLOSE c_minisite_id;
        ELSE -- LITE
           /* l_web_content_id is CTDID */
          OPEN c_minisite_id_lite(l_web_content_id);
          FETCH c_minisite_id_lite INTO l_minisite_id;
          CLOSE c_minisite_id_lite;
        END IF;
    END IF;

    IF (l_minisite_id > 0) THEN
     -- validate the minisite at iStore
      IF (isMinisite_iStore(l_minisite_id)) THEN
        l_media_rec.source_item_id := l_minisite_id;
        l_media_rec.media_item_ref := '671';
      END IF;
    END IF;
    -- End Minisite Population

  JTF_IH_PUB.open_mediaitem(
      p_api_version     => 1.0,
      p_init_msg_list   => FND_API.g_false,
      p_commit          => FND_API.g_false,
      p_resp_appl_id    => FND_GLOBAL.resp_appl_id,
      p_resp_id         => FND_GLOBAL.resp_id,
      p_user_id         => FND_GLOBAL.user_id,
      p_login_id        => FND_GLOBAL.conc_login_id,
      x_return_status   => l_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      p_media_rec       => l_media_rec,
      x_media_id        => l_media_id
   );

   IF l_return_status <> FND_API.g_ret_sts_success THEN
     RAISE FND_API.g_exc_error;
   END IF;

  -- JTF_IH_PUB.close_mediaitem
     l_media_rec.media_id := l_media_id;

     JTF_IH_PUB.close_mediaitem(
      p_api_version     => 1.0,
      p_init_msg_list   => FND_API.g_false,
      p_commit          => FND_API.g_false,
      p_resp_appl_id    => FND_GLOBAL.resp_appl_id,
      p_resp_id         => FND_GLOBAL.resp_id,
      p_user_id         => FND_GLOBAL.user_id,
      p_login_id        => FND_GLOBAL.conc_login_id,
      x_return_status   => l_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      p_media_rec       => l_media_rec
   );

   IF l_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

   /* Bug fix:5594167 */

   select source_code_id,arc_source_code_for  into code_id,obj_type  from  ams_source_codes  ascd where (ascd.source_code=p_track_rec.obj_src_code);

 --IF (p_track_rec.obj_type = 'CSCH')
      --THEN

   -- insert_log_mesg('obj_type from src_codes tbl::' || obj_type);

   IF (obj_type = 'CSCH')
   THEN
       select distinct owner_user_id, activity_id, activity_type_code into l_resource_id, l_activity_id, l_activity_type from AMS_CAMPAIGN_SCHEDULES_B csched
	   where (csched.source_code=p_track_rec.obj_src_code);

   ELSIF ( (obj_type = 'EONE') OR (obj_type = 'EVEO') )
   THEN
       -- l_resource_id := 100001738;
       select owner_user_id into l_resource_id from ams_event_offers_all_b eve  where (eve.source_code=p_track_rec.obj_src_code);
       l_activity_id := 20;
       l_activity_type := 'EMAIL';
   ELSE
       l_resource_id := 100001738;
       l_activity_id := 20;
       l_activity_type := 'EMAIL';
   END IF;

   /* insert_log_mesg('l_resource_id' || l_resource_id);
   insert_log_mesg('l_activity_id' || l_activity_id);
   insert_log_mesg('l_activity_type' || l_activity_type); */

   -- select source_code_id  into code_id  from  ams_source_codes  ascd where (ascd.source_code=p_track_rec.obj_src_code); --Moving up

   /* End bug fix: 5594167 */

   if (l_activity_id = 40) then
     l_action_item_id := 82; -- Web Offer
   elsif (l_activity_id = 30) then
     l_action_item_id := 81; -- Web Ad
   elsif (l_activity_id = 20) then
     l_action_item_id := 83; -- Email Link
   elsif (l_activity_id = 510) then
     l_action_item_id := 100; -- Web Prod
  -- db added the following logic for Pretty url tracking in IH
   elsif ((l_activity_id <> 20) and( l_activity_id <> 460)) then
      l_action_item_id := 106; -- pretty URL.
   elsif ((l_activity_type = 'BROADCAST') OR(l_activity_type = 'PUBLIC_RELATIONS')OR(l_activity_type= 'IN_STORE')) then
     l_action_item_id := 106; -- All advertising and Press Relations.
     -- END Pretty url tracking in IH
   else
     l_action_item_id := 81; -- Web ad for the others
   end if;

   IF (p_track_rec.flavour <> 'LITE') THEN
      if(l_activity_id = 20) then
        l_activity_rec.doc_ref := 'EMAIL';
      else
        l_activity_rec.doc_ref := 'POSTING';
      end if;
   ELSE
      /* Not correct for emails */
      --IF (p_track_rec.flavour = 'LITE') THEN
      l_activity_rec.doc_ref := 'IMPRESSION_TRACK';
   END IF;

   l_activity_rec.start_date_time  := SYSDATE;
   l_activity_rec.end_date_time    := SYSDATE;
   l_activity_rec.media_id         := l_media_id;
   l_activity_rec.action_id        := 79;
   l_activity_rec.action_item_id   := l_action_item_id;
   l_activity_rec.outcome_id       := 7;
   l_activity_rec.result_id        := 31;
   l_activity_rec.source_code      := p_track_rec.obj_src_code;
   l_activity_rec.source_code_id   := code_id;
   IF (p_track_rec.flavour <> 'LITE') THEN
     l_activity_rec.doc_id         := p_track_rec.posting_id;
   ELSE
     l_activity_rec.doc_id	   := p_track_rec.web_tracking_id;
   END IF;
   l_activity_rec.doc_source_object_name := p_track_rec.offer_src_code;

   SELECT jtf_ih_interactions_s1.NEXTVAL INTO l_interaction_id FROM dual;
   x_interaction_id := l_interaction_id;

   l_interaction_rec.interaction_id  := l_interaction_id;
   l_interaction_rec.start_date_time := SYSDATE;
   l_interaction_rec.end_date_time   := SYSDATE;
   l_interaction_rec.handler_id      := 530;
   l_interaction_rec.outcome_id      := 7;
   l_interaction_rec.result_id       := 31;
   l_interaction_rec.resource_id     := l_resource_id;
   l_interaction_rec.party_id        := p_track_rec.party_id;
   l_interaction_rec.source_code     := p_track_rec.obj_src_code;
   l_interaction_rec.source_code_id  := code_id;

   l_activity_tbl(1) := l_activity_rec;

   JTF_IH_PUB. create_interaction(
    p_api_version       => 1.0,
    p_init_msg_list     => FND_API.g_false,
    p_commit    	=> FND_API.g_false,
    p_resp_appl_id   	=> FND_GLOBAL.resp_appl_id,
    p_resp_id    	=> FND_GLOBAL.resp_id,
    p_user_id   	=> FND_GLOBAL.user_id,
    p_login_id    	=> FND_GLOBAL.conc_login_id,
    x_return_status 	=> l_return_status,
    x_msg_count   	=> l_msg_count,
    x_msg_data    	=> l_msg_data,
    p_interaction_rec   => l_interaction_rec,
    p_activities        => l_activity_tbl
    );


    IF l_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
    END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

       -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count  =>   x_msg_count,
         p_data   =>   x_msg_data
      );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Log_interaction;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Log_interaction;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Log_interaction;
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
End Log_interaction;


PROCEDURE Log_redirect(
    tracking_rec    IN  interaction_track_rec_type := g_miss_ps_strats_rec,
    x_redirect_url  OUT  NOCOPY  VARCHAR2,
    x_interaction_id  OUT  NOCOPY  NUMBER ,
    x_action_parameter_code   OUT  NOCOPY  VARCHAR2
)
 IS

L_API_NAME             CONSTANT VARCHAR2(30) := 'Log_redirect';
L_API_VERSION_NUMBER   CONSTANT NUMBER := 1.0;
-- Local Variables
    l_profile                VARCHAR2(1);
    x_return_status          VARCHAR2(1);
    x_msg_count              NUMBER;
    x_msg_data               VARCHAR2(2000);
    p_init_msg_list          VARCHAR2(2000);
    p_commit                 VARCHAR2(2000);
    l_interaction_id         NUMBER := null;
    l_action_parameter_code  VARCHAR2(2000) := null;
    l_redirect_url           VARCHAR2(2000) := null;
 BEGIN
      -- Standard Start of API savepoint
        SAVEPOINT Log_redirect;
   p_init_msg_list   := FND_API.G_FALSE;
   p_commit   := FND_API.G_FALSE;
     -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
     FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_profile := FND_PROFILE.VALUE('AMS_LOG_INTERACTION') ;

    IF (l_profile='Y' or tracking_rec.did <> null) THEN

  Log_interaction( p_api_version_number => 1.0,
      p_init_msg_list      =>  FND_API.G_FALSE,
      p_commit             =>  FND_API.G_TRUE,
      p_validation_level   =>  FND_API.G_VALID_LEVEL_FULL,

      x_return_status      =>  x_return_status,
      x_msg_count          =>  x_msg_count,
      x_msg_data           =>  x_msg_data,
      x_interaction_id  =>  l_interaction_id,
      p_track_rec         =>  tracking_rec
      );

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   x_interaction_id :=  l_interaction_id;
   get_redirect_url
    (
      tracking_rec.web_content_id,
      l_redirect_url,
      l_action_parameter_code
     );
--  x_redirect_url := l_redirect_url;
--  x_action_parameter_code :=  l_action_parameter_code;

    ELSE
   get_redirect_url
    (
      tracking_rec.web_content_id,
      l_redirect_url,
      l_action_parameter_code
     );
--  x_redirect_url := l_redirect_url;
--  x_action_parameter_code :=  l_action_parameter_code;

    END IF;

        x_redirect_url := l_redirect_url;
  x_action_parameter_code :=  l_action_parameter_code;

    -- End of API body.

     -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
           COMMIT WORK;
       END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Log_redirect;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Log_redirect;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Log_redirect;
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

   End Log_redirect;



   PROCEDURE get_redirect_url(
        p_web_content_id IN NUMBER,
        x_redirect_url   OUT NOCOPY VARCHAR2,
        x_action_parameter_code   OUT  NOCOPY  VARCHAR2  )
   IS
   BEGIN
        SAVEPOINT get_redirect_url;
              x_redirect_url := NULL;
        x_action_parameter_code := NULL;

        IF (p_web_content_id IS NOT NULL) THEN
    select display_url, link_to
    into x_redirect_url, x_action_parameter_code
    from jtf_amv_attachments
    where attachment_id = p_web_content_id;
        END IF;
    End get_redirect_url;

   PROCEDURE weblite_log(tracking_rec IN  interaction_track_rec_type := g_miss_ps_strats_rec,
		 x_interaction_id  OUT NOCOPY NUMBER,
		 x_msource  	   OUT NOCOPY NUMBER,
		 x_return_status   OUT NOCOPY VARCHAR2,
		 x_msg_count       OUT NOCOPY NUMBER,
		 x_msg_data        OUT NOCOPY VARCHAR2
	     )
    IS

   l_api_name             CONSTANT VARCHAR2(30) := 'weblite_log';
   l_api_version_number   CONSTANT NUMBER   := 1.0;
   -- Local Variables
   l_profile 		VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   p_init_msg_list      VARCHAR2(2000);
   p_commit             VARCHAR2(2000);
   l_interaction_id     NUMBER := null;
   l_obj_src_code       VARCHAR2(150);
   l_code_id 	        NUMBER := null;

   CURSOR c_code_id(p_code VARCHAR2) IS
     SELECT source_code_id FROM ams_source_codes
     WHERE source_code = p_code;

   BEGIN

   --insert_log_mesg('Very first statement of weblite log');

   -- Standard Start of API savepoint
         SAVEPOINT weblite_log;
   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   p_init_msg_list   := FND_API.G_FALSE;
   p_commit   := FND_API.G_FALSE;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_profile := FND_PROFILE.VALUE('AMS_LOG_INTERACTION') ;

--insert_log_mesg('Profile: Log Interaction: '||l_profile);

   IF (l_profile = 'Y') THEN
   Log_interaction( p_api_version_number => 1.0,
          p_init_msg_list      =>  FND_API.G_FALSE,
          p_commit             =>  FND_API.G_TRUE,
          p_validation_level   =>  FND_API.G_VALID_LEVEL_FULL,
          x_return_status      =>  x_return_status,
          x_msg_count          =>  x_msg_count,
          x_msg_data           =>  x_msg_data,
          x_interaction_id     =>  l_interaction_id,
          p_track_rec          =>  tracking_rec
    );
    END IF;

--insert_log_mesg('Log Interaction return status: '||x_return_status);
--insert_log_mesg('Interaction Id: '||l_interaction_id);

    --if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      --for i in 1..x_msg_count
      --loop
       --insert_log_mesg('Message count: '||x_msg_count);
       --insert_log_mesg('Message Data: '||x_msg_data);
      --end loop;
    --end if;

--insert_log_mesg('Obj Source Code: '||tracking_rec.obj_src_code);

    IF (tracking_rec.obj_src_code IS NOT NULL ) THEN
       l_obj_src_code := tracking_rec.obj_src_code;
       OPEN c_code_id(l_obj_src_code);
           fetch c_code_id into l_code_id;
       CLOSE c_code_id;
    END IF;
--insert_log_mesg('Msource: '||l_code_id);

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_interaction_id :=  l_interaction_id;
    x_msource := l_code_id;

    -- End of API body.

     -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

--insert_log_mesg('Leaving weblitelog Happily !!!:)');
      -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

   EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO weblite_log;
     x_return_status := FND_API.G_RET_STS_ERROR;
--insert_log_mesg('amsvtrkb:weblitelog:FND_API.G_EXC_ERROR');
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO weblite_log;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--insert_log_mesg('amsvtrkb:weblitelog:FND_API.G_EXC_UNEXPECTED_ERROR');
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO weblite_log;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--insert_log_mesg('amsvtrkb:weblitelog:OTHERS');
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

   End weblite_log;

END AMS_TRACKING_PVT;

/
