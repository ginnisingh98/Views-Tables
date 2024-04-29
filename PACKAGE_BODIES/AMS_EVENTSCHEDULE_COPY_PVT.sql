--------------------------------------------------------
--  DDL for Package Body AMS_EVENTSCHEDULE_COPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTSCHEDULE_COPY_PVT" AS
/* $Header: amsvescb.pls 120.6 2006/05/16 02:04:26 batoleti noship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='AMS_EventSchedule_Copy_PVT';
g_file_name  CONSTANT VARCHAR2(12):='amsvescb.pls';
G_OBJECT_TYPE_MODEL       CONSTANT VARCHAR2(30) := 'EVEO';

G_ATTRIBUTE_GEOS          CONSTANT VARCHAR2(30) := 'GEOS';
G_ATTRIBUTE_CELL          CONSTANT VARCHAR2(30) := 'CELL';
-- Debug mode
-- g_debug boolean := FALSE;
-- g_debug boolean := TRUE;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Copy_event_offer
--
--   Description
--           To support the "Copy Event Schedules" functionality from the events overview
--           and detail pages.
--
--   History
--      12-MAY-2001   PMOTHUKU  Created this available procedures below
--                    Implemented the procedures separetly so that they
--      31-Jul-2002   GMADANA  Copying Start date time and End date time for
--                    Event Schedule.
--   ==============================================================================

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION get_agenda_name (p_agenda_id IN NUMBER)
      RETURN VARCHAR2
   IS
      -- PL/SQL Block
      l_name   VARCHAR2 (256);
        CURSOR c_agenda_name(p_agenda_id IN NUMBER)    IS
        SELECT   event_offer_name
          FROM     ams_event_offers_vl
          WHERE  parent_event_offer_id = p_agenda_id;

   BEGIN

      OPEN c_agenda_name(p_agenda_id);
      FETCH c_agenda_name INTO l_name;
      CLOSE c_agenda_name;

      RETURN '"' || l_name || '" ';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '"' || p_agenda_id || '"';
   END get_agenda_name;

PROCEDURE copy_act_delivery_method(
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num              NUMBER;
      l_name                  VARCHAR2 (80);
      l_mesg_text             VARCHAR2 (2000);
      l_api_version           NUMBER;
      l_return_status         VARCHAR2 (1);
      x_msg_count             NUMBER;
      l_msg_data              VARCHAR2 (512);
      l_act_deliverable_id   NUMBER;
      l_deliverables_rec     ams_associations_pvt.association_rec_type;
      l_temp_deliverables_rec     ams_associations_pvt.association_rec_type;
      l_lookup_meaning        VARCHAR2 (80);

      CURSOR deliverable_cur
      IS
         SELECT
         DLT.deliverable_name ,
         DLV.custom_setup_id,
         CAT.category_id,
         OBJ.master_object_id,
         OBJ.object_association_id,
         OBJ.using_object_id,
         CAT.category_name ,
         OBJ.object_version_number,
         OBJ.quantity_needed,
         OBJ.fulfill_on_type_code,
         OBJ.master_object_type,
         OBJ.quantity_needed_by_date,
		 OBJ.USING_OBJECT_TYPE,
          OBJ.primary_flag,
	  OBJ.USAGE_TYPE
	FROM
	 AMS_OBJECT_ASSOCIATIONS OBJ,
	 AMS_DELIVERABLES_ALL_B DLV,
	AMS_DELIVERABLES_ALL_TL DLT,
	 AMS_CATEGORIES_TL CAT
	WHERE
	 OBJ.master_object_id = p_src_act_id AND
	 OBJ.USING_OBJECT_TYPE = 'DELV' AND
	 OBJ.USING_OBJECT_ID = DLV.DELIVERABLE_ID AND
	 OBJ.USING_OBJECT_ID = DLT.DELIVERABLE_ID AND
	 DLT.LANGUAGE = USERENV('LANG') AND
	 DLV.CATEGORY_TYPE_ID = CAT.CATEGORY_ID AND
	 CAT.LANGUAGE = USERENV('LANG') AND
	 OBJ.master_object_type =p_src_act_type;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      l_stmt_num := 1;
IF p_src_act_id IS NOT NULL THEN
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('the  deliverable copying: ');
END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the  p_src_act_id: ' ||  p_src_act_id||'\n');
 END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the  p_new_act_id: ' ||  p_new_act_id||'\n');
 END IF;
 END IF;
      FOR deliverable_rec IN deliverable_cur
      LOOP
         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_deliverables_rec := l_temp_deliverables_rec;
            l_deliverables_rec.master_object_id:= p_new_act_id;
            l_deliverables_rec.master_object_type:=  NVL(p_new_act_type,p_src_act_type);

            l_deliverables_rec.using_object_id:= deliverable_rec.using_object_id;
            l_deliverables_rec.object_version_number:= deliverable_rec.object_version_number;
            l_deliverables_rec.quantity_needed := NULL;
            l_deliverables_rec.fulfill_on_type_code := deliverable_rec.fulfill_on_type_code;
            l_deliverables_rec.quantity_needed_by_date := deliverable_rec.quantity_needed_by_date;
			   l_deliverables_rec.using_object_type:= deliverable_rec.using_object_type;
            l_deliverables_rec.usage_type:= deliverable_rec.usage_type;
            l_deliverables_rec.primary_flag:= deliverable_rec.primary_flag;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
               ams_associations_pvt.create_association(
               p_api_version => l_api_version,
               p_init_msg_list => fnd_api.g_true,
               p_commit=>fnd_api.g_true,
               p_validation_level=> FND_API.g_valid_level_full,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
                p_association_rec => l_deliverables_rec,
			    	x_object_association_id => l_act_deliverable_id
                );


         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           END IF;
           EXCEPTION
             WHEN OTHERS THEN p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
              END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errcode := SQLCODE;
         p_errnum := 4;
         l_stmt_num := 5;
         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
         fnd_message.set_token ('ELEMENTS','AMS_COPY_DELIVMETHODS', TRUE);
         l_mesg_text := fnd_message.get;
         p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                              ',' || '): ' || p_errcode || SQLERRM, 1, 4000);
         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                             p_src_act_id,
                                             p_errmsg,
                                             'ERROR'
                                          );
   END copy_act_delivery_method;

/* PROCEDURE copy_event_schedule_agenda(
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
 l_stmt_num          NUMBER;
      l_name              VARCHAR2 (80);
      l_mesg_text         VARCHAR2 (2000);
      l_api_version       NUMBER;
      l_return_status     VARCHAR2 (1);
      x_msg_count         NUMBER;
      l_msg_data          VARCHAR2 (512);
      l_act_agenda_id   NUMBER;
      l_agenda_rec   AMS_EventOffer_PVT.evo_rec_type;
      temp_agenda_rec   AMS_EventOffer_PVT.evo_rec_type;
      l_lookup_meaning    VARCHAR2 (80);
 CURSOR agenda_cur IS
 select
      EVENT_OFFER_ID
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
	 ,OBJECT_VERSION_NUMBER
	 ,APPLICATION_ID
	 ,PRIVATE_FLAG
	 ,ACTIVE_FLAG
	 ,SOURCE_CODE
	 ,EVENT_LEVEL
	 ,USER_STATUS_ID
	 ,LAST_STATUS_DATE
	 ,SYSTEM_STATUS_CODE
	 ,EVENT_TYPE_CODE
	 ,EVENT_DELIVERY_METHOD_ID
	 ,''
	 ,EVENT_REQUIRED_FLAG
	 ,EVENT_LANGUAGE_CODE
	 ,EVENT_LOCATION_ID
	 ,''
	 ,''
	 ,''
	 ,''
	 ,OVERFLOW_FLAG
	 ,PARTNER_FLAG
	 ,EVENT_STANDALONE_FLAG
	 ,REG_FROZEN_FLAG
	 ,REG_REQUIRED_FLAG
	 ,REG_CHARGE_FLAG
	 ,REG_INVITED_ONLY_FLAG
	 ,REG_WAITLIST_ALLOWED_FLAG
	 ,REG_OVERBOOK_ALLOWED_FLAG
	 ,PARENT_EVENT_OFFER_ID
	 ,EVENT_DURATION
	 ,EVENT_DURATION_UOM_CODE
	, EVENT_START_DATE
	 ,EVENT_START_DATE_TIME
	 ,EVENT_END_DATE
	 ,EVENT_END_DATE_TIME
	 ,REG_START_DATE
	 ,REG_START_TIME
	 ,REG_END_DATE
	 ,REG_END_TIME
	 ,REG_MAXIMUM_CAPACITY
	 ,REG_OVERBOOK_PCT
	 ,REG_EFFECTIVE_CAPACITY
	 ,REG_WAITLIST_PCT
	 ,REG_MINIMUM_CAPACITY
	 ,REG_MINIMUM_REQ_BY_DATE
	 ,INVENTORY_ITEM_ID
	 ,''
	 ,ORGANIZATION_ID
	 ,PRICELIST_header_ID
	 ,PRICELIST_LINE_ID
	 ,ORG_ID
	 ,WAITLIST_ACTION_TYPE_CODE
	 ,STREAM_TYPE_CODE
	 ,OWNER_USER_ID
	 ,EVENT_FULL_FLAG
	 ,FORECASTED_REVENUE
	 ,ACTUAL_REVENUE
	 ,FORECASTED_COST
	 ,ACTUAL_COST
	 ,FUND_SOURCE_TYPE_CODE
	 ,FUND_SOURCE_ID
	 ,CERT_CREDIT_TYPE_CODE
	 ,CERTIFICATION_CREDITS
	 ,COORDINATOR_ID
	 ,PRIORITY_TYPE_CODE
	 ,CANCELLATION_REASON_CODE
	 ,AUTO_REGISTER_FLAG
	 ,EMAIL
	 ,PHONE
	 ,FUND_AMOUNT_TC
	 ,FUND_AMOUNT_FC
	 ,CURRENCY_CODE_TC
	 ,CURRENCY_CODE_FC
	 ,URL
	 ,TIMEZONE_ID
	,EVENT_VENUE_ID
	,''
	,''
	,INBOUND_SCRIPT_NAME
	,ATTRIBUTE_CATEGORY
	,ATTRIBUTE1
	,ATTRIBUTE2
	 ,ATTRIBUTE3
	 ,ATTRIBUTE4
	 ,ATTRIBUTE5
	 ,ATTRIBUTE6
	 ,ATTRIBUTE7
	,ATTRIBUTE8
	 ,ATTRIBUTE9
	 ,ATTRIBUTE10
	 ,ATTRIBUTE11
	 ,ATTRIBUTE12
	 ,ATTRIBUTE13
	 ,ATTRIBUTE14
	 ,ATTRIBUTE15
	 ,EVENT_OFFER_NAME
	 ,EVENT_MKTG_MESSAGE
	 ,DESCRIPTION
	 ,SETUP_TYPE_ID
	 ,COUNTRY_CODE
	 ,BUSINESS_UNIT_ID
	 ,EVENT_CALENDAR
	 ,START_PERIOD_NAME
	 ,END_PERIOD_NAME
	 ,GLOBAL_FLAG
	 ,TASK_ID
	 --PROGRAM_ID
	 ,PARENT_TYPE
	 ,PARENT_ID
	,CREATE_ATTENDANT_LEAD_FLAG
	,CREATE_REGISTRANT_LEAD_FLAG
	,EVENT_OBJECT_TYPE
	,REG_TIMEZONE_ID
	,event_password
,record_event_flag
,allow_register_in_middle_flag
,publish_attendees_flag
,direct_join_flag
,event_notification_method
,actual_start_time
,actual_end_time
,SERVER_ID
,owner_fnd_user_id
,meeting_dial_in_info
,meeting_email_subject
,meeting_schedule_type
,meeting_status
,meeting_misc_info
,publish_flag
,meeting_encryption_key_code
,number_of_attendees
,EVENT_PURPOSE_CODE
 FROM ams_event_offers_vl
 WHERE parent_event_offer_id =  p_src_act_id
      AND event_level='SUB';
  BEGIN
 p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'AGEN',
                                           l_return_status,
                                           l_lookup_meaning
                                        );
      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                       );
      l_stmt_num := 1;
 IF p_src_act_id IS NOT NULL THEN
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the  p_src_act_id: ' ||  p_src_act_id||'\n');
 END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the  p_new_act_id: ' ||  p_new_act_id||'\n');
 END IF;
 END IF;
      FOR agenda_rec IN agenda_cur
      LOOP
         BEGIN
             p_errcode := NULL;
             p_errnum := 0;
             p_errmsg := NULL;
             l_api_version := 1.0;
             l_return_status := NULL;
             x_msg_count := 0;
             l_msg_data := NULL;
             l_act_agenda_id:=0;
             l_agenda_rec.parent_event_offer_id := p_new_act_id;
              l_agenda_rec.event_object_type:= agenda_rec.event_object_type;
             l_agenda_rec.event_offer_name:= agenda_rec.event_offer_name;
	     l_agenda_rec.EVENT_START_DATE:= agenda_rec.EVENT_START_DATE;
             l_agenda_rec.EVENT_START_DATE:= agenda_rec.EVENT_START_DATE;
             l_agenda_rec.application_id:=530;
             l_agenda_rec.EVENT_START_DATE_TIME:= agenda_rec.EVENT_START_DATE_TIME;

             l_agenda_rec.EVENT_END_DATE_TIME:= agenda_rec.EVENT_END_DATE_TIME;
             l_agenda_rec.EVENT_START_DATE:= agenda_rec.EVENT_START_DATE;
             l_agenda_rec.owner_user_id:=agenda_rec.owner_user_id;
             l_agenda_rec.event_level:='SUB';
             l_agenda_rec.user_status_id:=agenda_rec.user_status_id;

      AMS_EventOffer_PVT.create_event_offer (
       p_api_version  => 1.0,
       p_init_msg_list   => FND_API.G_FALSE,
       p_commit          => FND_API.G_FALSE,
       p_validation_level   =>  FND_API.g_valid_level_full,
       p_evo_rec       => l_agenda_rec,
       x_return_status   => l_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => l_msg_data,
       x_evo_id          => l_act_agenda_id
      );

     IF (AMS_DEBUG_HIGH_ON) THEN



         AMS_UTILITY_PVT.debug_message('the  p_act_agenda_id: ' || l_act_agenda_id||'\n');

     END IF;




         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
           l_mesg_text := fnd_message.get;

           p_errmsg := SUBSTR ( l_mesg_text || ' - ' ||
                               AMS_EventSchedule_Copy_PVT.get_agenda_name (
                                  agenda_rec.parent_event_offer_id
                                ), 1, 4000);
           ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                               p_src_act_id,
                                               p_errmsg,
                                               'ERROR'
                                            );
           END IF;
             EXCEPTION
                WHEN OTHERS THEN
                   p_errcode := SQLCODE;
                   p_errnum := 3;
                   l_stmt_num := 4;
                   fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
                   fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                   l_mesg_text := fnd_message.get;
                   p_errmsg := SUBSTR ( l_mesg_text ||
                                        ',' || TO_CHAR (l_stmt_num) ||
                                        ',' || '): ' || p_errcode ||
                                        SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text ||
                                   AMS_EventSchedule_Copy_PVT.get_agenda_name (
                                       agenda_rec.parent_event_offer_id
                                    ) || p_errmsg, 1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
               END;
            END LOOP;

           EXCEPTION
              WHEN OTHERS
              THEN
                 p_errcode := SQLCODE;
                 p_errnum := 4;
                 l_stmt_num := 5;
                 fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
                 fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                 l_mesg_text := fnd_message.get;
                 p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                                      ',' || '): ' || p_errcode || SQLERRM,
                                       1, 4000);
                 ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                     p_src_act_id,
                                                     p_errmsg,
                                                     'ERROR'
                                                  );
   END copy_event_schedule_agenda;
*/

   -- soagrawa 12-may-2003 recoded the following procedure for bug# 2949268 for 11.5.8
PROCEDURE copy_event_schedule_agenda(
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY     NUMBER,
      p_errcode        OUT NOCOPY     VARCHAR2,
      p_errmsg         OUT NOCOPY     VARCHAR2
   )
IS
      l_stmt_num          NUMBER;
      l_name              VARCHAR2 (80);
      l_mesg_text         VARCHAR2 (2000);
      l_api_version       NUMBER;
      l_return_status     VARCHAR2 (1);
      x_msg_count         NUMBER;
      l_msg_data          VARCHAR2 (512);
      l_act_track_id      NUMBER;
      l_act_session_id    NUMBER;
      l_lookup_meaning    VARCHAR2 (80);

      l_new_track_cur     Ams_agendas_pvt.agenda_rec_type ;
      l_new_session_cur   Ams_agendas_pvt.agenda_rec_type ;

      l_old_ev_st_dt         DATE;
      l_old_ev_end_dt        DATE;
      l_new_ev_st_dt         DATE;
      l_new_ev_end_dt        DATE;

      l_old_ev_duration      NUMBER;
      l_new_ev_duration      NUMBER;

      CURSOR c_track_cur IS
      SELECT coordinator_id, parent_type,parent_id,agenda_name,description,agenda_type, b.agenda_id --* perf fix
        FROM ams_agendas_b b, ams_agendas_tl tl--ams_agendas_v SQL Rep perf fix
       WHERE b.agenda_id = tl.agenda_id
         AND tl.language = USERENV('LANG')
         AND parent_id = p_src_act_id
         AND agenda_type = 'TRACK'
         AND active_flag = 'Y';                   --bug fix 3097466 by anchaudh on 14-Aug-2003.

      CURSOR c_session_cur(p_track_id NUMBER) IS
      SELECT coordinator_id,parent_type,parent_id,agenda_name,description,agenda_type,b.agenda_id,
             start_date_time, end_date_time
        FROM ams_agendas_b b, ams_agendas_tl tl --ams_agendas_v SQL Rep Perf Fix
       WHERE b.agenda_id = tl.agenda_id
         AND tl.language = USERENV('LANG')
         AND parent_id = p_track_id
         AND agenda_type = 'SESSION'
         AND active_flag = 'Y';                    --bug fix 3097466 by anchaudh on 14-Aug-2003.

      CURSOR c_ev_offer_det (p_event_offer_id NUMBER) IS
      SELECT event_start_date, event_end_date
        FROM ams_event_offers_all_b
       WHERE event_offer_id = p_event_offer_id;

  BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;

      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'AGEN',
                                           l_return_status,
                                           l_lookup_meaning
                                        );

      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);

      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                       );

      l_stmt_num := 1;
      IF p_src_act_id IS NOT NULL THEN
              IF (AMS_DEBUG_HIGH_ON) THEN
                  AMS_UTILITY_PVT.debug_message('the  p_src_act_id: ' ||  p_src_act_id||'\n');
              END IF;
            IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_UTILITY_PVT.debug_message('the  p_new_act_id: ' ||  p_new_act_id||'\n');
            END IF;
      END IF;

      OPEN  c_ev_offer_det (p_src_act_id);
      FETCH c_ev_offer_det INTO l_old_ev_st_dt, l_old_ev_end_dt;
      CLOSE c_ev_offer_det;

      l_old_ev_duration := l_old_ev_end_dt - l_old_ev_st_dt;

      OPEN  c_ev_offer_det (p_new_act_id);
      FETCH c_ev_offer_det INTO l_new_ev_st_dt, l_new_ev_end_dt;
      CLOSE c_ev_offer_det;

      l_new_ev_duration := l_new_ev_end_dt - l_new_ev_st_dt;

      FOR l_track_cur IN c_track_cur
      LOOP
         BEGIN

             p_errcode := NULL;
             p_errnum := 0;
             p_errmsg := NULL;
             l_api_version := 1.0;
             l_return_status := NULL;
             x_msg_count := 0;
             l_msg_data := NULL;
             l_act_track_id :=0;

             l_new_track_cur.coordinator_id          := l_track_cur.coordinator_id;
             l_new_track_cur.parent_type             := l_track_cur.parent_type;
             l_new_track_cur.agenda_name             := l_track_cur.agenda_name;
             l_new_track_cur.description             := l_track_cur.description;
             l_new_track_cur.agenda_type             := 'TRACK';
             l_new_track_cur.application_id          := 530;
             l_new_track_cur.parent_id               := p_new_act_id;

             AMS_AGENDAS_PVT.create_agenda (
                p_api_version      => 1.0,
                p_init_msg_list    => FND_API.G_FALSE,
                p_commit           => FND_API.G_FALSE,
                p_validation_level =>  FND_API.g_valid_level_full,
                p_agenda_rec       => l_new_track_cur,
                x_return_status    => l_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => l_msg_data,
                x_agenda_id        => l_act_track_id
             );

         IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_UTILITY_PVT.debug_message('the  p_act_agenda_id: ' || l_act_track_id||'\n');
         END IF;
             IF l_return_status = fnd_api.g_ret_sts_error
                OR l_return_status = fnd_api.g_ret_sts_unexp_error
             THEN
                FOR l_counter IN 1 .. x_msg_count
                LOOP
                  l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
                  l_stmt_num := 2;
                  p_errnum := 1;
                  p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                     ' , ' || '): ' || l_counter ||
                                     ' OF ' || x_msg_count, 1, 4000);
                   ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                      p_src_act_id,
                                                      p_errmsg,
                                                      'ERROR'
                                                     );
                END LOOP;

                fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
                fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                l_mesg_text := fnd_message.get;

                p_errmsg := SUBSTR ( l_mesg_text || ' - ' ||
                                     AMS_EventSchedule_Copy_PVT.get_agenda_name (
                                        l_track_cur.agenda_id
                                      ), 1, 4000);
                ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                     p_src_act_id,
                                                     p_errmsg,
                                                     'ERROR'
                                                  );
             ELSE
                -- creating track was successful
                -- now create sessions
                FOR l_session_cur IN c_session_cur(l_track_cur.agenda_id)
                LOOP

                      p_errcode := NULL;
                      p_errnum := 0;
                      p_errmsg := NULL;
                      l_api_version := 1.0;
                      l_return_status := NULL;
                      x_msg_count := 0;
                      l_msg_data := NULL;
                      l_act_session_id := null;

                      l_new_session_cur.coordinator_id          := l_session_cur.coordinator_id;
                      l_new_session_cur.parent_type             := 'TRACK';
                      l_new_session_cur.agenda_name             := l_session_cur.agenda_name;
                      l_new_session_cur.description             := l_session_cur.description;
                      l_new_session_cur.agenda_type             := 'SESSION';
                      l_new_session_cur.application_id          := 530;
                      l_new_session_cur.parent_id               := l_act_track_id;
                      -- soagrawa 28-may-2003 removed copying room for reopened bug# 2949268
                      --l_new_session_cur.room_id                 := l_session_cur.room_id;


                      l_new_session_cur.start_date_time         := l_new_ev_st_dt + (l_session_cur.start_date_time - l_old_ev_st_dt ) ;
                      l_new_session_cur.end_date_time           := l_new_session_cur.start_date_time + (l_session_cur.end_date_time - l_session_cur.start_date_time);

                      IF l_new_ev_duration < l_old_ev_duration
                      THEN
                         IF l_new_session_cur.start_date_time < l_new_ev_st_dt
                            OR l_new_session_cur.end_date_time > l_new_ev_end_dt
                         THEN
                            l_new_session_cur.start_date_time := l_new_ev_end_dt - (l_session_cur.end_date_time - l_session_cur.start_date_time);
                            l_new_session_cur.end_date_time := l_new_ev_end_dt;
                         END IF;
                      END IF;

                      AMS_AGENDAS_PVT.create_agenda (
                         p_api_version      => 1.0,
                         p_init_msg_list    => FND_API.G_FALSE,
                         p_commit           => FND_API.G_FALSE,
                         p_validation_level =>  FND_API.g_valid_level_full,
                         p_agenda_rec       => l_new_session_cur,
                         x_return_status    => l_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => l_msg_data,
                         x_agenda_id        => l_act_session_id
                      );

                      IF l_return_status = fnd_api.g_ret_sts_error
                         OR l_return_status = fnd_api.g_ret_sts_unexp_error
                      THEN

                         FOR l_counter IN 1 .. x_msg_count
                         LOOP
                           l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
                           l_stmt_num := 2;
                           p_errnum := 1;
                           p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                              ' , ' || '): ' || l_counter ||
                                              ' OF ' || x_msg_count, 1, 4000);
                            ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                               p_src_act_id,
                                                               p_errmsg,
                                                               'ERROR'
                                                              );
                         END LOOP;

                         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
                         fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                         l_mesg_text := fnd_message.get;

                         p_errmsg := SUBSTR ( l_mesg_text || ' - ' ||
                                              AMS_EventSchedule_Copy_PVT.get_agenda_name (
                                                 l_session_cur.agenda_id
                                               ), 1, 4000);
                         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                              p_src_act_id,
                                                              p_errmsg,
                                                              'ERROR'
                                                           );
                         END IF;

                END LOOP;
             END IF;

             EXCEPTION
                WHEN OTHERS THEN
                         p_errcode := SQLCODE;
                         p_errnum := 3;
                         l_stmt_num := 4;
                         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
                         fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                         l_mesg_text := fnd_message.get;
                         p_errmsg := SUBSTR ( l_mesg_text ||
                                              ',' || TO_CHAR (l_stmt_num) ||
                                              ',' || '): ' || p_errcode ||
                                              SQLERRM, 1, 4000);
                         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
                         fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                         l_mesg_text := fnd_message.get;
                         p_errmsg := SUBSTR ( l_mesg_text ||
                                            AMS_EventSchedule_Copy_PVT.get_agenda_name (
                                                l_new_track_cur.agenda_id
                                             ) || p_errmsg, 1, 4000);
                         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                            p_src_act_id,
                                                            p_errmsg,
                                                            'ERROR'
                                                         );
                END;
      END LOOP;

  EXCEPTION
              WHEN OTHERS
              THEN
                 p_errcode := SQLCODE;
                 p_errnum := 4;
                 l_stmt_num := 5;
                 fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
                 fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                 l_mesg_text := fnd_message.get;
                 p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                                      ',' || '): ' || p_errcode || SQLERRM,
                                       1, 4000);
                 ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                     p_src_act_id,
                                                     p_errmsg,
                                                     'ERROR'
                                                  );
END copy_event_schedule_agenda;



PROCEDURE copy_event_schedule(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_source_object_id           IN   NUMBER,
    p_attributes_table           IN   AMS_CpyUtility_PVT.copy_attributes_table_type,
    p_copy_columns_table         IN   AMS_CpyUtility_PVT.copy_columns_table_type,

    x_new_object_id              OUT NOCOPY  NUMBER,
    x_custom_setup_id            OUT NOCOPY  NUMBER
     )
IS

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'create_event_offer';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 2;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_event_offer_id            NUMBER :=p_source_object_id;
   l_new_event_offer_id        NUMBER;
   l_dummy                     NUMBER;
   p_event_offer_rec           AMS_EVENTOFFER_PVT.evo_rec_type;
   l_evo_rec                   AMS_EVENTOFFER_PVT.evo_rec_type;
   l_reference_rec             AMS_EventOffer_PVT.evo_rec_type;
   l_event_offer_rec           AMS_EventOffer_PVT.evo_rec_type;
   l_new_reference_rec         AMS_EventOffer_PVT.evo_rec_type;
   l_return_status             VARCHAR2(1);
   l_errnum                    NUMBER;
   l_errcode                   VARCHAR2(30);
   l_errmsg                    VARCHAR2(4000);
   --l_msg_count               NUMBER;
   --l_msg_data                VARCHAR2;
   l_custom_setup_id           NUMBER := 1;
   l_event_object_type         VARCHAR2(30);
   l_dlvmthd_code              VARCHAR2(30);
   l_start_date                DATE := NULL;
   l_end_date                  DATE := NULL;
   l_ARC_ACT_CATEGORY_USED_BY  VARCHAR2(30);
   l_rec_cnt                   NUMBER;

   CURSOR c_dlvmthd_code( event_offer_id IN NUMBER) IS
   SELECT delivery_media_type_code
   FROM Ams_act_delivery_methods
   WHERE act_delivery_method_used_by_id = event_offer_id;

   CURSOR c_event_times( event_offer_id_in IN NUMBER) IS
   SELECT event_start_date, event_end_date
   FROM ams_event_offers_vl
   WHERE event_offer_id = event_offer_id_in;


 BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT copy_event_schedule;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
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
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('the source object id: ' ||  p_source_object_id||'\n');
    END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('the new source object id: ' ||  x_new_object_id||'\n');
    END IF;
     IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('the source custom setup id: ' ||   x_custom_setup_id||'\n');
     END IF;
     FOR i IN 1..p_copy_columns_table.COUNT LOOP
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_UTILITY_PVT.debug_message('the'||i||'copy column name: '|| p_copy_columns_table(i).column_name||'\n');
           END IF;
	   IF (AMS_DEBUG_HIGH_ON) THEN

	       AMS_UTILITY_PVT.debug_message('the'||i||'copy column value: '|| p_copy_columns_table(i).column_value||'\n');
	   END IF;
          END LOOP;
    FOR i IN 1..p_attributes_table.COUNT LOOP
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_UTILITY_PVT.debug_message('the'||i||'attibute: '||p_attributes_table(i));
        END IF;
      END LOOP;
   -- Initialize API return status to SUCCESS
  -- x_return_status := FND_API.G_RET_STS_SUCCESS;


   --
   -- Start of API body
   --

   -- ----------------------------
   -- fetch source object details
   -- ----------------------------
   AMS_EVENTOFFER_PVT.init_evo_rec(p_event_offer_rec);
   p_event_offer_rec.event_offer_id:=p_source_object_id;
   p_event_offer_rec.EVENT_DELIVERY_METHOD_CODE :=NULL;
   AMS_EVENTOFFER_PVT.complete_evo_rec(p_event_offer_rec,l_evo_rec);
   l_event_object_type:=l_evo_rec.event_object_type;
   l_reference_rec:=l_evo_rec;
   l_event_offer_rec:=l_evo_rec;
   l_event_offer_rec.event_offer_id := null;
  -- l_event_offer_rec.source_code := null;
   -- ------------------------------
   -- copy all required fields
   -- i.e. copy values of all mandatory columns from the copy UI
   -- Mandatory fields for EVEH are EventName,EventOfferId,Start Date and End Date
   -- for ams_event_evos_all_b table :
   -- ------------------------------

   OPEN c_event_times(p_event_offer_rec.event_offer_id);
   FETCH c_event_times INTO l_start_date, l_end_date;
   CLOSE c_event_times;


   AMS_CpyUtility_PVT.get_column_value ('startDate', p_copy_columns_table, l_event_offer_rec.EVENT_START_DATE);
   l_event_offer_rec.EVENT_START_DATE:= NVL (l_event_offer_rec.EVENT_START_DATE,l_reference_rec.EVENT_START_DATE);
   AMS_CpyUtility_PVT.get_column_value ('endDate', p_copy_columns_table, l_event_offer_rec.EVENT_END_DATE);
   l_event_offer_rec.EVENT_END_DATE:= NVL ( l_event_offer_rec.EVENT_END_DATE, l_reference_rec.EVENT_END_DATE);

   IF(l_start_date = l_event_offer_rec.EVENT_START_DATE)
   THEN
       AMS_CpyUtility_PVT.get_column_value ('startTime', p_copy_columns_table, l_event_offer_rec.EVENT_START_DATE_TIME);
       l_event_offer_rec.EVENT_START_DATE_TIME:= NVL (l_event_offer_rec.EVENT_START_DATE_TIME,l_reference_rec.EVENT_START_DATE_TIME);
   ELSE
       l_event_offer_rec.EVENT_START_DATE_TIME:=NULL;
   END IF;

   IF(l_end_date = l_event_offer_rec.EVENT_END_DATE)
   THEN
       AMS_CpyUtility_PVT.get_column_value ('endTime', p_copy_columns_table, l_event_offer_rec.EVENT_END_DATE_TIME);
       l_event_offer_rec.EVENT_END_DATE_TIME:= NVL ( l_event_offer_rec.EVENT_END_DATE_TIME, l_reference_rec.EVENT_END_DATE_TIME);
   ELSE
       l_event_offer_rec.EVENT_END_DATE_TIME:=NULL;
   END IF;

   AMS_CpyUtility_PVT.get_column_value ('newObjName', p_copy_columns_table, l_event_offer_rec.event_offer_name);
   l_event_offer_rec.event_offer_name:= NVL ( l_event_offer_rec.event_offer_name, l_reference_rec.event_offer_name);
   AMS_CpyUtility_PVT.get_column_value ('ownerId', p_copy_columns_table, l_event_offer_rec.owner_user_id);
   l_event_offer_rec.owner_user_id:= NVL (l_event_offer_rec.owner_user_id, l_reference_rec.owner_user_id);
   AMS_CpyUtility_PVT.get_column_value ('newSrcCode', p_copy_columns_table, l_event_offer_rec.source_code);
   l_event_offer_rec.source_code:= NVL (l_event_offer_rec.source_code, NULL);
   AMS_CpyUtility_PVT.get_column_value ('countryId', p_copy_columns_table, l_event_offer_rec.country_code);
   l_event_offer_rec.country_code:= NVL (l_event_offer_rec.country_code, l_reference_rec.country_code);
   AMS_CpyUtility_PVT.get_column_value ('langCode', p_copy_columns_table, l_reference_rec.event_language_code);
   l_event_offer_rec.event_language_code:= NVL (l_event_offer_rec.event_language_code, l_reference_rec.event_language_code);
   AMS_CpyUtility_PVT.get_column_value ('currency', p_copy_columns_table, l_reference_rec.currency_code_tc);
   l_event_offer_rec.currency_code_tc:= NVL (l_event_offer_rec.currency_code_tc, l_reference_rec.currency_code_tc);

   -- -------------------------------------------
   -- fields not to be copied
   -- -------------------------------------------




    l_event_offer_rec.event_venue_id             := NULL;
    l_event_offer_rec.business_unit_id           := NULL;
    l_event_offer_rec.reg_start_date             := NULL;
    l_event_offer_rec.reg_end_date               := NULL;
   -- l_event_offer_rec.event_delivery_method_id   := NULL;
    l_event_offer_rec.city                       :=NULL;
    l_event_offer_rec.state                      :=NULL;
    l_event_offer_rec.country                    :=NULL;
    l_event_offer_rec.description                :=NULL;
    l_event_offer_rec.start_period_name          :=NULL;
    l_event_offer_rec.end_period_name            := NULL;
    l_event_offer_rec.user_status_id             :=NULL;
    l_event_offer_rec.priority_type_code         :=NULL;
    l_event_offer_rec.INVENTORY_ITEM_ID          :=NULL;
    l_event_offer_rec.PRICELIST_HEADER_ID        :=NULL;
    l_event_offer_rec.PRICELIST_LINE_ID          :=NULL;
    l_event_offer_rec.FORECASTED_REVENUE         :=NULL;
    l_event_offer_rec.ACTUAL_REVENUE             :=NULL;
    l_event_offer_rec.FORECASTED_COST            :=NULL;
    l_event_offer_rec.ACTUAL_COST                :=NULL;
    l_event_offer_rec.FUND_SOURCE_TYPE_CODE      :=NULL;
    l_event_offer_rec.FUND_SOURCE_ID             :=NULL;
    l_event_offer_rec.FUND_AMOUNT_FC             :=NULL;
    l_event_offer_rec.FUND_AMOUNT_TC             :=NULL;


    -- Get the Delivery Method Code of the Event Schedule to be Copied(Source)
    -- and copy it for the new Event Schedule to be created.
    open c_dlvmthd_code(l_event_offer_id);
    fetch c_dlvmthd_code into l_dlvmthd_code;
    IF c_dlvmthd_code%NOTFOUND THEN
      close c_dlvmthd_code;
    ELSE
      l_event_offer_rec.event_delivery_method_code   := l_dlvmthd_code;
      close c_dlvmthd_code;
    END IF;

     -- ----------------------------
   -- call create api
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('offerId: ' || l_event_offer_rec.event_offer_id || 'start\n');
 END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('deliverable stuff: ' || l_event_offer_rec.event_delivery_method_code);
 END IF;

 l_event_offer_rec.object_version_number := 2;
 -- DBMS_OUTPUT.put_line('calling create with ');
AMS_EventOffer_PVT.create_event_offer (
      p_api_version  => 1.0,
      p_init_msg_list   => FND_API.G_FALSE,
      p_commit          => FND_API.G_FALSE,
      p_validation_level   =>  FND_API.g_valid_level_full,
      p_evo_rec       => l_event_offer_rec,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,

      x_evo_id          => l_new_event_offer_id
   );

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the l_event_header_id: ' || l_event_offer_id||'\n');
 END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the l_new_event_header_id: ' || l_new_event_offer_id||'\n');
 END IF;
   -- copy agenda

 -- soagrawa 12-may-2003 uncommented for bug# 2949268 for 11.5.10
IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_EventSchedule_Copy_PVT.G_ATTRIBUTE_AGEN , p_attributes_table) = FND_API.G_TRUE THEN
      copy_event_schedule_agenda (
         p_src_act_type   => l_event_object_type,
         p_new_act_type   => l_event_object_type,
         p_src_act_id     => l_event_offer_id,
         p_new_act_id     => l_new_event_offer_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
        );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- copy resources
   /*Commented by mukemar on may14 2002 we are not supporting the resource copy
   IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_EventSchedule_Copy_PVT.G_ATTRIBUTE_RESC, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_resources (
         p_src_act_type   => l_event_object_type,
         p_new_act_type   => l_event_object_type,
         p_src_act_id     => l_event_offer_id,
         p_new_act_id     => l_new_event_offer_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
   END IF;
   */
   -- copy categories
IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_EventSchedule_Copy_PVT.G_ATTRIBUTE_CATG, p_attributes_table) = FND_API.G_TRUE THEN
      -- batoleti Ref bug# 5213664
      -- get the object type from act_actegories based on the original evet_offer_id..

      l_ARC_ACT_CATEGORY_USED_BY := NULL;
      l_rec_cnt := 0;

      select count(*) into l_rec_cnt
      FROM ams_act_categories
      where ACT_CATEGORY_USED_BY_ID = l_event_offer_id;

      IF (l_rec_cnt > 0) THEN

         SELECT ARC_ACT_CATEGORY_USED_BY
         INTO l_ARC_ACT_CATEGORY_USED_BY
         FROM ams_act_categories
         where ACT_CATEGORY_USED_BY_ID = l_event_offer_id;

     END IF;

      AMS_CopyElements_PVT.copy_act_categories (
         p_src_act_type   => nvl(l_ARC_ACT_CATEGORY_USED_BY,G_OBJECT_TYPE_MODEL),
         p_new_act_type   => nvl(l_ARC_ACT_CATEGORY_USED_BY,G_OBJECT_TYPE_MODEL),
         p_src_act_id     => l_event_offer_id,
         p_new_act_id     => l_new_event_offer_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_EventSchedule_Copy_PVT.G_ATTRIBUTE_PROD, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_prod (
         p_src_act_type   => l_event_object_type,
         p_new_act_type   => l_event_object_type,
         p_src_act_id     => l_event_offer_id,
         p_new_act_id     => l_new_event_offer_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
IF AMS_CpyUtility_PVT.is_copy_attribute (G_ATTRIBUTE_GEOS, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_geo_areas (
         p_src_act_type   => l_event_object_type,
         p_new_act_type   => l_event_object_type,
         p_src_act_id     => l_event_offer_id,
         p_new_act_id     => l_new_event_offer_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
IF AMS_CpyUtility_PVT.is_copy_attribute (G_ATTRIBUTE_CELL, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_market_segments (
         p_src_act_type   => l_event_object_type,
         p_new_act_type   => l_event_object_type,
         p_src_act_id     => l_event_offer_id,
         p_new_act_id     => l_new_event_offer_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_EventSchedule_Copy_PVT.G_ATTRIBUTE_MESG, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_messages(
         p_src_act_type   => l_event_object_type,
         p_new_act_type   => l_event_object_type,
         p_src_act_id     => l_event_offer_id,
         p_new_act_id     => l_new_event_offer_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
IF AMS_CpyUtility_PVT.is_copy_attribute(AMS_Event_Objects_Copy_PVT.G_ATTRIBUTE_DELV, p_attributes_table) = FND_API.G_TRUE THEN
    copy_act_delivery_method(
         p_src_act_type   => l_event_object_type,
         p_new_act_type   => l_event_object_type,
         p_src_act_id     => l_event_offer_id,
         p_new_act_id     => l_new_event_offer_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );




      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
  p_event_offer_rec.event_offer_id:=l_new_event_offer_id;
   AMS_EVENTOFFER_PVT.complete_evo_rec(p_event_offer_rec,l_new_reference_rec);

    x_new_object_id:= l_new_event_offer_id;
    x_custom_setup_id:= l_new_reference_rec.custom_setup_id;


   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO copy_event_schedule;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO copy_event_schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO copy_event_schedule;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );


END copy_event_schedule;

END AMS_EventSchedule_Copy_PVT;

/
