--------------------------------------------------------
--  DDL for Package Body AMS_EVENTHEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTHEADER_PVT" AS
/* $Header: amsvevhb.pls 120.2 2006/04/25 09:53:26 vmodur noship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='AMS_EventHeader_PVT';
g_file_name  CONSTANT VARCHAR2(12):='amsvevhb.pls';


-- Debug mode
-- g_debug boolean := FALSE;
-- g_debug boolean := TRUE;

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Check_Dates_Range (
        p_evh_rec          IN  evh_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Parent_Active (
        p_evh_rec          IN  evh_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2
);


PROCEDURE Update_Metrics (
        p_evh_rec          IN  evh_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2,
   x_msg_count OUT NOCOPY VARCHAR2,
   x_msg_data OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_event_header
--
-- HISTORY
--    11/17/1999  gdeodhar  Created.
--        01/17/2000  gdeodhar  Changed the procedure to pick up the
--                                                      correct user_status_id and system_status_code.
--                                                      Fixed the time formats.
--                                                      Added code to generate source_code.
---------------------------------------------------------------------
PROCEDURE create_event_header(
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
        p_commit            IN  VARCHAR2  := FND_API.g_false,
        p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2,

        p_evh_rec          IN  evh_rec_type,
        x_evh_id           OUT NOCOPY NUMBER
)
IS

        l_api_version CONSTANT NUMBER       := 1.0;
        l_api_name    CONSTANT VARCHAR2(30) := 'create_event_header';
        l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

        l_return_status VARCHAR2(1);
        l_source_code_id  NUMBER;
        l_evh_rec       evh_rec_type := p_evh_rec;
        l_evh_count     NUMBER;

        l_start_time            DATE;
        l_end_time              DATE;
        l_user_id  NUMBER;
        l_res_id   NUMBER;
        l_org_id   NUMBER;
        l_ovn      NUMBER(9) := 1;


        CURSOR c_evh_seq IS
                SELECT ams_event_headers_all_b_s.NEXTVAL
                FROM DUAL;

        CURSOR c_evh_count(evh_id IN NUMBER) IS
                SELECT COUNT(*)
                FROM ams_event_headers_vl
                WHERE event_header_id = evh_id;

        CURSOR c_evh_status_evagd(ust_id IN NUMBER) IS
                SELECT system_status_code
                FROM ams_user_statuses_b
                WHERE user_status_id = ust_id
                AND system_status_type = 'AMS_EVENT_AGENDA_STATUS';

        CURSOR get_res_id(l_user_id IN NUMBER) IS
                SELECT resource_id
                FROM ams_jtf_rs_emp_v
                WHERE user_id = l_user_id;

BEGIN

   --------------------- initialize -----------------------
        SAVEPOINT create_event_header;

        IF (AMS_DEBUG_HIGH_ON) THEN



            AMS_Utility_PVT.debug_message(l_full_name||': start');

        END IF;

        IF FND_API.to_boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF NOT FND_API.compatible_api_call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name
                                                    ) THEN
                RAISE FND_API.g_exc_unexpected_error;
        END IF;

        x_return_status := FND_API.g_ret_sts_success;
--------------- calendar----------------------------
-- added sugupta 08/28/20000--------------
-- default event calendar, present;y defailting it to be same as campaigns calendar.. SHOULD CHANGE
-- not sure about the logic, should it be defaulted only for MAIN events, not the agenda..
--  IF l_evh_rec.event_calendar IS NULL THEN
        l_evh_rec.event_calendar := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
 --  END IF;

 -- we will override any coming value of system status code
-- added sugupta 07/20/2000 for event agenda, stastuses shouldnt be defaulted to 1/NEW
-- for main event, while creation.. user status shud always be 1, system status always NEW
        if l_evh_rec.event_level = 'MAIN' then
                l_evh_rec.user_status_id := ams_utility_pvt.get_default_user_status('AMS_EVENT_STATUS','NEW');
                l_evh_rec.system_status_code := 'NEW';
        else
                -- pick up the correct system_status_code
                IF l_evh_rec.user_status_id IS NOT NULL THEN
                        OPEN c_evh_status_evagd(l_evh_rec.user_status_id);
                        FETCH c_evh_status_evagd INTO l_evh_rec.system_status_code;
                        CLOSE c_evh_status_evagd;
                END IF;
        end if;

   ----------------------- validate -----------------------
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message(l_full_name ||': validate');
        END IF;

        validate_event_header(
                p_api_version        => l_api_version,
                p_init_msg_list      => p_init_msg_list,
                p_validation_level   => p_validation_level,
                x_return_status      => l_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data,
                p_evh_rec            => l_evh_rec
        );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
--------------- CHECK ACCESS FOR THE USER ONLY FOR EVENT AGENDA-------------------
----------added sugupta 07/25/2000
        IF l_evh_rec.event_level = 'SUB' THEN
                l_user_id := FND_GLOBAL.User_Id;
                IF (AMS_DEBUG_HIGH_ON) THEN

                    AMS_Utility_PVT.debug_message(' CHECK ACCESS l_user_id is ' ||l_user_id );
                END IF;
                if l_user_id IS NOT NULL then
                        open get_res_id(l_user_id);
                        fetch get_res_id into l_res_id;
                        close get_res_id;
                end if;
                if AMS_ACCESS_PVT.check_update_access(l_evh_rec.parent_event_header_id, 'EVEH', l_res_id, 'USER') = 'N' then
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                                FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS');-- reusing the message
                                FND_MSG_PUB.add;
                        END IF;
                        RAISE FND_API.g_exc_error;
                end if;
        ELSIF l_evh_rec.event_level = 'MAIN' THEN
       null;

   END IF;

        IF l_evh_rec.event_level = 'MAIN' THEN
                null;
                /* Hornet :call Task creation API  ThisAPI is not yet coded */
   END IF;

-- ==========================================================
-- Following code is added by mukumar on 10/30/2000
-- the code will convert the transaction currency in to
-- functional currency.
-- ==========================================================

    IF (l_evh_rec.event_level = 'MAIN' AND l_evh_rec.fund_amount_tc IS NOT NULL )THEN
       AMS_EvhRules_PVT.Convert_Evnt_Currency(
          p_tc_curr     => l_evh_rec.currency_code_tc,
          p_tc_amt      => l_evh_rec.fund_amount_tc,
          x_fc_curr     => l_evh_rec.currency_code_fc,
          x_fc_amt      => l_evh_rec.fund_amount_fc
       ) ;
        END IF ;
   -------------------------- insert --------------------------
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message(l_full_name ||': Get Sequence');
        END IF;

        IF l_evh_rec.event_header_id IS NULL THEN
                LOOP
                        OPEN c_evh_seq;
                        FETCH c_evh_seq INTO l_evh_rec.event_header_id;
                        CLOSE c_evh_seq;

                        OPEN c_evh_count(l_evh_rec.event_header_id);
                        FETCH c_evh_count INTO l_evh_count;
                        CLOSE c_evh_count;

                        EXIT WHEN l_evh_count = 0;
                END LOOP;
        END IF;


-- Global flag if not passed from the screen, default it as N
        IF l_evh_rec.global_flag IS NULL THEN
                l_evh_rec.global_flag := 'N';
        END IF;

-- if incoming source_code is NULL, it is generated only for event_level = 'MAIN'
   IF l_evh_rec.source_code IS NULL
                AND l_evh_rec.event_level = 'MAIN'
                THEN
                -- choang - 16-May-2000
                -- Replaced get_source_code with get_new_source_code
                -- for internal rollout requirement #20.
                -- MODIFIED SUGUPTA 05/30/2000 get_new_source_code FUNCTION NOT INCLUDED IN
                --  11.5.1.0.4 RELEASE.. SO COMMENTING OUT THIS FUNCTION CALL AND
                -- UNCOMMENTING OLD FUNCTION CALL TO USE OLD FN. get_source_code TO GET SOURCE CODE
                -- *****SHOULD REVERT THIS IN LATER REVISIONS TO USE NEW SOURCE CODE FUNCTIONS****
                -- choang - 07-Jul-2000
                -- Re-introduce get_new_source_code for internal rollout/R2
                -- NOTE: need to implement global flag.
                l_evh_rec.source_code := AMS_SourceCode_PVT.get_new_source_code (
                                                                                                                                p_object_type     => 'EVEH',
                                                                                                                                p_custsetup_id    => l_evh_rec.custom_setup_id,
                                                                                                                                p_global_flag     => l_evh_rec.global_flag
                                                                                                                        );
                --l_evh_rec.source_code := AMS_SourceCode_PVT.get_source_code(
                --                                                                              'EVEH',
                --                                                                              l_evh_rec.event_type_code
                --                                                               );
        END IF;

        IF (AMS_DEBUG_HIGH_ON) THEN



            AMS_Utility_PVT.debug_message(l_full_name ||': Source Code');

        END IF;

-- convert incoming time entries appropriately.
        IF l_evh_rec.agenda_start_time IS NOT NULL THEN
                l_start_time := to_date(to_char(l_evh_rec.agenda_start_time, 'HH24:MI'),'HH24:MI');
                l_evh_rec.agenda_start_time := l_start_time;
        END IF;
        IF l_evh_rec.agenda_end_time IS NOT NULL THEN
                l_end_time := to_date(to_char(l_evh_rec.agenda_end_time, 'HH24:MI'),'HH24:MI');
                l_evh_rec.agenda_end_time := l_end_time;
        END IF;

  /* Code Added By GMadana for date/time validation for Agendas*/
   IF l_start_time > l_end_time THEN
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error)
      THEN
        Fnd_Message.set_name('AMS', 'AMS_EVO_START_TM_GT_END_TM'); -- reusing EVEO message
        Fnd_Msg_Pub.ADD;
        END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
                RAISE Fnd_Api.g_exc_error;
   END IF; -- st tm > end tm

   /* Code Added by GMADANA for Date validation for attaching Program as Parent */
   /* Check_Dates_Range has date validation for MAIN level  as agenda for Event Header
      has no dates on the GUI.
   */

   IF (p_evh_rec.event_level = 'MAIN') THEN
     Check_Dates_Range(
         p_evh_rec    => p_evh_rec,
         x_return_status      => x_return_status
      );

      IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                   RAISE Fnd_Api.g_exc_unexpected_error;
           ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
                   RAISE Fnd_Api.g_exc_error;
      END IF;
         END IF;



        -------------------------- insert --------------------------
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message(l_full_name ||': insert B');
        END IF;
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message(l_full_name ||': insert B1'||l_evh_rec.agenda_start_time||','||l_evh_rec.agenda_end_time);
        END IF;
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message(l_full_name ||': insert B2'||l_evh_rec.active_from_date||','||l_evh_rec.active_to_date);
        END IF;

         -- Added by rmajumda (09/15/05). MOAC changes
         l_org_id := fnd_profile.value('DEFAULT_ORG_ID');

         IF l_evh_rec.object_version_number = 2 THEN -- copy
            l_ovn := 2;
         END IF;


        INSERT INTO ams_event_headers_all_b(
                event_header_id
                ,setup_type_id
                ,last_update_date
                ,last_updated_by
                ,creation_date
                ,created_by
                ,last_update_login
                ,object_version_number
                ,event_level
                ,application_id
                ,event_type_code
                ,active_flag
                ,private_flag
                ,user_status_id
                ,system_status_code
                ,last_status_date
                ,stream_type_code
                ,source_code
                ,event_standalone_flag
                ,day_of_event
                ,agenda_start_time
                ,agenda_end_time
                ,reg_required_flag
                ,reg_charge_flag
                ,reg_invited_only_flag
                ,partner_flag
                ,overflow_flag
                ,parent_event_header_id
                ,duration
                ,duration_uom_code
                ,active_from_date
                ,active_to_date
                ,reg_maximum_capacity
                ,reg_minimum_capacity
                ,main_language_code
                ,cert_credit_type_code
                ,certification_credits
                ,inventory_item_id
                ,organization_id
                ,org_id
                ,forecasted_revenue
                ,actual_revenue
                ,forecasted_cost
                ,actual_cost
                ,coordinator_id
                ,fund_source_type_code
                ,fund_source_id
                ,fund_amount_tc
                ,fund_amount_fc
                ,currency_code_tc
                ,currency_code_fc
                ,owner_user_id
                ,url
                ,phone
                ,email
                ,priority_type_code
                ,cancellation_reason_code
                ,inbound_script_name
                ,attribute_category
                ,attribute1
                ,attribute2
                ,attribute3
                ,attribute4
                ,attribute5
                ,attribute6
                ,attribute7
                ,attribute8
                ,attribute9
                ,attribute10
                ,attribute11
                ,attribute12
                ,attribute13
                ,attribute14
                ,attribute15
                ,country_code
                ,business_unit_id
                ,event_calendar
                ,start_period_name
                ,end_period_name
                ,global_flag
                ,task_id
                ,program_id
                ,CREATE_ATTENDANT_LEAD_FLAG /*hornet*/
                ,CREATE_REGISTRANT_LEAD_FLAG /*hornet*/
                ,EVENT_PURPOSE_CODE    /*hornet*/
        )
        VALUES(
                l_evh_rec.event_header_id,
                l_evh_rec.custom_setup_id,
                SYSDATE,
                FND_GLOBAL.user_id,
                SYSDATE,
                FND_GLOBAL.user_id,
                FND_GLOBAL.conc_login_id,
                l_ovn,
                l_evh_rec.event_level,                                  -- MAIN (event header), SUB (agenda item)
                                                                        -- Level will be sent by the UI.
                l_evh_rec.application_id,
                l_evh_rec.event_type_code,
                NVL(l_evh_rec.active_flag, 'Y'),                        -- it is set to Y if it is null.
                NVL(l_evh_rec.private_flag,'N'),                        -- Value will come from the User Interface.
                l_evh_rec.user_status_id,                                       -- This is defaulted to 1 for level=MAIN
                l_evh_rec.system_status_code,                           -- This is defaulted to 'NEW' for level=MAIN
                NVL(l_evh_rec.last_status_date,SYSDATE),
                l_evh_rec.stream_type_code,
                l_evh_rec.source_code,                                  -- If the incoming value is NULL, it is generated.
                NVL(l_evh_rec.event_standalone_flag,'N'),       -- Value will come from the User Interface.
                l_evh_rec.day_of_event,
                l_evh_rec.agenda_start_time,                            -- This is converted appropriately
                l_evh_rec.agenda_end_time,                              -- This is converted appropriately
                NVL(l_evh_rec.reg_required_flag,'Y'),           -- Value will come from the UI.
                NVL(l_evh_rec.reg_charge_flag,'Y'),             -- Value will come from the UI.
                NVL(l_evh_rec.reg_invited_only_flag,'N'),       -- Value will come from the UI.
                NVL(l_evh_rec.partner_flag,'N'),
                NVL(l_evh_rec.overflow_flag,'N'),                       -- Value will come from the UI.
                l_evh_rec.parent_event_header_id,
                l_evh_rec.duration,
                l_evh_rec.duration_uom_code,
                l_evh_rec.active_from_date,
                l_evh_rec.active_to_date,
                l_evh_rec.reg_maximum_capacity,
                l_evh_rec.reg_minimum_capacity,
                l_evh_rec.main_language_code,
                l_evh_rec.cert_credit_type_code,
                l_evh_rec.certification_credits,
                l_evh_rec.inventory_item_id,
                l_evh_rec.organization_id,
                --TO_NUMBER(SUBSTRB(userenv('CLIENT_INFO'),1,10)),        -- org_id
                l_org_id,
                l_evh_rec.forecasted_revenue,
                l_evh_rec.actual_revenue,
                l_evh_rec.forecasted_cost,
                l_evh_rec.actual_cost,
                l_evh_rec.coordinator_id,
                l_evh_rec.fund_source_type_code,
                l_evh_rec.fund_source_id,
                l_evh_rec.fund_amount_tc,
                l_evh_rec.fund_amount_fc,
                l_evh_rec.currency_code_tc,
                l_evh_rec.currency_code_fc,
                l_evh_rec.owner_user_id,
                l_evh_rec.url,
                l_evh_rec.phone,
                l_evh_rec.email,
                l_evh_rec.priority_type_code,
                l_evh_rec.cancellation_reason_code,
                l_evh_rec.inbound_script_name,
                l_evh_rec.attribute_category,
                l_evh_rec.attribute1,
                l_evh_rec.attribute2,
                l_evh_rec.attribute3,
                l_evh_rec.attribute4,
                l_evh_rec.attribute5,
                l_evh_rec.attribute6,
                l_evh_rec.attribute7,
                l_evh_rec.attribute8,
                l_evh_rec.attribute9,
                l_evh_rec.attribute10,
                l_evh_rec.attribute11,
                l_evh_rec.attribute12,
                l_evh_rec.attribute13,
                l_evh_rec.attribute14,
                l_evh_rec.attribute15,
        --      l_evh_rec.country_code,
        --      The above will require the JSP to send the country_code as part of the rec.
        --      This is not needed the API can pick it up as follows:
                NVL(l_evh_rec.country_code, TO_NUMBER(FND_PROFILE.value('AMS_SRCGEN_USER_CITY'))),
        --      The above picks up the country code from the Profile option if the one sent in
        --      by the JSP page is null.
                l_evh_rec.business_unit_id,
        --      The JSPs are expected to send the value of the business_unit_id. It is nullable.
                l_evh_rec.event_calendar,
                l_evh_rec.start_period_name,
                l_evh_rec.end_period_name,
                nvl(l_evh_rec.global_flag, 'N'),
        --above 4 fields added to be in synch with campaigns
                l_evh_rec.task_id, /*hornet create Taskid */
                l_evh_rec.program_id /*hornet create Taskid */
                ,l_evh_rec.CREATE_ATTENDANT_LEAD_FLAG /*hornet*/
                ,l_evh_rec.CREATE_REGISTRANT_LEAD_FLAG /*hornet*/
                ,l_evh_rec.EVENT_PURPOSE_CODE /*hornet*/
        );

        IF (AMS_DEBUG_HIGH_ON) THEN



            AMS_Utility_PVT.debug_message(l_full_name ||': insert TL');

        END IF;

        INSERT INTO ams_event_headers_all_tl(
                event_header_id,
                language,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                source_lang,
                event_header_name,
                event_mktg_message,
                description
   )
   SELECT
                l_evh_rec.event_header_id,
                l.language_code,
                SYSDATE,
                FND_GLOBAL.user_id,
                SYSDATE,
                FND_GLOBAL.user_id,
                FND_GLOBAL.conc_login_id,
                USERENV('LANG'),
                l_evh_rec.event_header_name,
                l_evh_rec.event_mktg_message,
                l_evh_rec.description
        FROM fnd_languages l
        WHERE l.installed_flag in ('I', 'B')
        AND NOT EXISTS(
                        SELECT NULL
                        FROM ams_event_headers_all_tl t
                        WHERE t.event_header_id = l_evh_rec.event_header_id
                        AND t.language = l.language_code );



   -- added by murali on may/2001
   -- create obj attributes for newly created master event
   -- Should do it only for 'MAIN' event level
        IF l_evh_rec.event_level = 'MAIN'  THEN
                AMS_EvhRules_PVT.push_source_code(
                        l_evh_rec.source_code,
                        'EVEH',
                        l_evh_rec.event_header_id
                );
        END IF;
-- The AMS_SourceCode_PVT takes care of inserting the newly generated
-- Source Code in ams_source_codes table.
   IF l_evh_rec.event_level = 'MAIN'  THEN
           -- attach seeded metrics
           AMS_RefreshMetric_PVT.copy_seeded_metric(
                  p_api_version => l_api_version,
                  x_return_status => l_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  p_arc_act_metric_used_by =>'EVEH',
                  p_act_metric_used_by_id => l_evh_rec.event_header_id,
                  p_act_metric_used_by_type => NULL
           );
           IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('Before Add_Update_Access_record');
           END IF;
        AMS_EvhRules_PVT.Add_Update_Access_record(p_object_type => 'EVEH',
                                                  p_object_id => l_evh_rec.event_header_id,
                                                  p_Owner_user_id => l_evh_rec.owner_user_id,
                                                  x_return_status => l_return_status,
                                                 x_msg_count          => x_msg_count,
                                                 x_msg_data           => x_msg_data);
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('After Add_Update_Access_record' || l_return_status);
           END IF;
   END IF; -- check for event level MAIN

   ------------------------- finish -------------------------------
   x_evh_id := l_evh_rec.event_header_id;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

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
      ROLLBACK TO create_event_header;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_event_header;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_event_header;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END create_event_header;


---------------------------------------------------------------
-- PROCEDURE
--    delete_event_header
--
-- HISTORY
--    11/17/1999  gdeodhar  Created.
---------------------------------------------------------------
PROCEDURE delete_event_header(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_event_header';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_hdr_id NUMBER;
   l_level  VARCHAR2(30);
   l_user_id  NUMBER;
   l_res_id   NUMBER;
   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;

   CURSOR get_parent_header_info(l_evh_id IN NUMBER) IS
   SELECT event_level,parent_event_header_id
   FROM ams_event_headers_all_b
   WHERE event_header_id = l_evh_id
   and   event_level = 'SUB';

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_event_header;

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --------------- CHECK ACCESS FOR THE USER-------------------
   ----------added sugupta 07/25/2000
        l_user_id := FND_GLOBAL.User_Id;
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message(' CHECK ACCESS l_user_id is ' ||l_user_id );
        END IF;
        if l_user_id IS NOT NULL then
                open get_res_id(l_user_id);
                fetch get_res_id into l_res_id;
                close get_res_id;
        end if;
        open get_parent_header_info(p_evh_id);
        fetch get_parent_header_info into l_level, l_hdr_id;
        close get_parent_header_info;
        IF (l_level <> 'SUB' OR l_level is NULL) THEN
                l_hdr_id := p_evh_id;
        END IF;
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message('l_hdr_id:'||l_hdr_id || 'P_evh_id:' || p_evh_id || 'l_res_id:' || l_res_id);
        END IF;
        if AMS_ACCESS_PVT.check_update_access(l_hdr_id, 'EVEH', l_res_id, 'USER') = 'N' then
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS'); --reusing the message
         FND_MSG_PUB.add;
                END IF;
                RAISE FND_API.g_exc_error;
        end if;
   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   UPDATE ams_event_headers_all_b
   SET active_flag = 'N'
   WHERE event_header_id = p_evh_id
   AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
/*
   DELETE FROM ams_event_headers_all_tl
   WHERE event_header_id = p_evh_id;
*/
   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

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
      ROLLBACK TO delete_event_header;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_event_header;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_event_header;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END delete_event_header;


-------------------------------------------------------------------
-- PROCEDURE
--    lock_event_header
--
-- HISTORY
--    11/17/1999  GDEODHAR  Created
--------------------------------------------------------------------
PROCEDURE lock_event_header(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'lock_event_header';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_evh_id      NUMBER;

   CURSOR c_evh_b IS
   SELECT event_header_id
     FROM ams_event_headers_all_b
    WHERE event_header_id = p_evh_id
      AND object_version_number = p_object_version
   FOR UPDATE OF event_header_id NOWAIT;

   CURSOR c_evh_tl IS
   SELECT event_header_id
     FROM ams_event_headers_all_tl
    WHERE event_header_id = p_evh_id
      AND USERENV('LANG') IN (language, source_lang)
   FOR UPDATE OF event_header_id NOWAIT;

BEGIN

   -------------------- initialize ------------------------
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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN c_evh_b;
   FETCH c_evh_b INTO l_evh_id;
   IF (c_evh_b%NOTFOUND) THEN
      CLOSE c_evh_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_evh_b;

   OPEN c_evh_tl;
   CLOSE c_evh_tl;

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

   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                   FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
                   FND_MSG_PUB.add;
                END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

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
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END lock_event_header;


---------------------------------------------------------------------
-- PROCEDURE
--    update_event_header
--
-- HISTORY
--    11/17/1999  gdeodhar  Created
--        01/17/2000  gdeodhar  Fixed the time formats.
--    01/21/2000  gdeodhar  Added code to pick up the system_status_code
--                                                      from ams_user_statuses_b table. The UI will
--                                                      never pass this code.
----------------------------------------------------------------------
PROCEDURE update_event_header(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec          IN  evh_rec_type
)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_event_header';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_evh_rec        evh_rec_type;
   l_global_flag    VARCHAR2(25);
   l_source_code    VARCHAR2(30);
   l_return_status  VARCHAR2(1);
   l_hdr_id  NUMBER;
   l_user_id  NUMBER;
   l_res_id   NUMBER;
   l_dummy    NUMBER;
   -- added by soagrawa for bug# 2761612 21-jan-2003
   l_dummy_source_code   VARCHAR2(30);

   CURSOR c_evh_status_evh IS
   SELECT system_status_code
   FROM ams_user_statuses_b
   WHERE user_status_id = p_evh_rec.user_status_id
     AND system_status_type = 'AMS_EVENT_STATUS';

   CURSOR c_evh_status_evagd IS
   SELECT system_status_code
   FROM ams_user_statuses_b
   WHERE user_status_id = p_evh_rec.user_status_id
     AND system_status_type = 'AMS_EVENT_AGENDA_STATUS';

   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;

   CURSOR c_bdgt_line_yn(id_in IN NUMBER, objtype_in IN VARCHAR2) IS
   SELECT count(*)
   FROM OZF_ACT_BUDGETS  --anchaudh: changed call from ams_act_budgets to ozf_act_budgets : bug#3453430
   WHERE arc_act_budget_used_by = objtype_in
   AND act_budget_used_by_id =id_in;

   CURSOR c_evh IS
   SELECT global_flag,source_code
   FROM ams_event_headers_vl
   WHERE event_header_id = p_evh_rec.event_header_id;


BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT update_event_header;

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate ----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   --
   -- Call the complete rec
   --
   -- replace g_miss_char/num/date with current column values

    -- The following procedure will pick up all the fields from p_evh_rec
        -- and copy them to l_evh_rec.
        -- For all missing fields in p_evh_rec, it will pick up the current
        -- column values and place in those fields.

   complete_evh_rec(p_evh_rec, l_evh_rec);

   -- add check evh update
   -- check if it is needed..

        -- Check if (budget lines are available added 06/04/2001 murali)
        IF (p_evh_rec.currency_code_tc <> FND_API.g_miss_char) THEN
                if (p_evh_rec.currency_code_tc <> nvl(l_evh_rec.currency_code_tc, '1') ) THEN
                        OPEN c_bdgt_line_yn(l_evh_rec.event_header_id, 'EVEH');
                        FETCH c_bdgt_line_yn INTO l_dummy;
                        IF c_bdgt_line_yn%NOTFOUND THEN
                                CLOSE c_bdgt_line_yn;
                        else
                                CLOSE c_bdgt_line_yn;
                                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                                        FND_MESSAGE.set_name('AMS', 'AMS_EVENT_BUD_PRESENT');
                                        FND_MSG_PUB.add;
                                END IF;
                                RAISE FND_API.g_exc_error;
                        END IF;
                END IF;
        END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||':before Rules_EVH_Update');

   END IF;

   AMS_EvhRules_PVT.check_evh_update(
         p_evh_rec       => p_evh_rec,
         x_return_status  => l_return_status
   );

   IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   ELSIF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||':after Rules_EVH_Update');

   END IF;

   -- item level validation

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_evh_items(
         p_evh_rec        => p_evh_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||':after check_evh_items');
   END IF;

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_evh_record(
         p_evh_rec       => p_evh_rec,
         p_complete_rec   => l_evh_rec,
         x_return_status  => l_return_status
      );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||':after check_evh_record');

   END IF;

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   -- inter-entity level
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_inter_entity THEN
      check_evh_inter_entity(
         p_evh_rec        => p_evh_rec,
         p_complete_rec    => l_evh_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||':after check_evh_inter_entity');

   END IF;

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   -- Handle status

   IF p_evh_rec.user_status_id <> FND_API.g_miss_num
   THEN

          -- looks like the following procedure needs the system_status_code
          -- as well.

                -- pick up the correct system_status_code first.
                IF l_evh_rec.event_level = 'MAIN'
                THEN
                        OPEN c_evh_status_evh;
                        FETCH c_evh_status_evh INTO l_evh_rec.system_status_code;
                        CLOSE c_evh_status_evh;
                ELSIF l_evh_rec.event_level = 'SUB'
                THEN
                        OPEN c_evh_status_evagd;
                        FETCH c_evh_status_evagd INTO l_evh_rec.system_status_code;
                        CLOSE c_evh_status_evagd;
                END IF;

      -- this following procedure must check if the user tried to update
          -- the status id. this will be clear if the new intended user_status_id
          -- is different than the current user_status_id.
          -- this should kick the status order rules and pick up the next
          -- correct status id for the record.
       -- 07/18/2000 sugupta check for statuses done in check_evh_update..
       -- the api call to handle_evh_status below is redundant ..


   IF (AMS_DEBUG_HIGH_ON) THEN





       AMS_Utility_PVT.debug_message(l_full_name ||': user_status_id = ' || l_evh_rec.user_status_id);


   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': system_status_code = ' || l_evh_rec.system_status_code);
   END IF;

         /*
         -- 01/21/2000 : gdeodhar
         -- commented out this call as it gives AMS_EVH_BAD_USER_STATUS
     -- error.
         -- Anyway, this is not doing anything currently.
         -- 01/25/2000 : gdeodhar
         -- Ravi fixed the AMS_EvhRules_PVT.handle_evh_status.
         -- Testing again.
         -- Well, it does not compile.
         -- SO COMMENTED IT AGAIN.
         -- 03/29/00 sugupta Corrected handle_evh_status .. uncommenting call to handle_evh_status
       -- 07/18/2000 sugupta check for statuses done in check_evh_update..
       -- the api call to handle_evh_status below is redundant ..


 --    AMS_EvhRules_PVT.handle_evh_status(
 --        l_evh_rec.user_status_id,
 --        l_evh_rec.system_status_code,
 --        l_return_status
 --     );

--       IF l_return_status = FND_API.g_ret_sts_error THEN
 --        RAISE FND_API.g_exc_error;
 --     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
 --        RAISE FND_API.g_exc_unexpected_error;
 --     END IF;
*/
   END IF;

      -- handle source code update
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': update source code:'||l_evh_rec.system_status_code);
   END IF;
   -- only for main and non active events

   /* Added by GMADANA */
   OPEN c_evh;
     FETCH c_evh INTO l_global_flag, l_source_code;
   CLOSE c_evh;

   IF p_evh_rec.source_code <> FND_API.g_miss_char
   THEN
      IF p_evh_rec.source_code <> l_source_code
      THEN
         IF l_evh_rec.event_level = 'MAIN'
         AND l_evh_rec.system_status_code  = 'NEW'
         -- commented by musman oct 10
         -- OR l_evh_rec.system_status_code = 'PLANNING') since the source code canbe update only in new status
         THEN
            IF (AMS_DEBUG_HIGH_ON) THEN

                    AMS_Utility_PVT.debug_message(l_full_name ||': update source code:'||l_evh_rec.system_status_code);
            END IF;

                 -- extracting out source code modified by soagrawa
                 -- 21-jan-2003 bug# 2761612
                 AMS_EvhRules_PVT.update_evh_source_code(
                         l_evh_rec.event_header_id,
                         l_evh_rec.source_code,
                         l_evh_rec.global_flag,
                         l_dummy_source_code,
                         l_return_status
                 );
                 l_evh_rec.source_code := l_dummy_source_code;
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                         RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                         RAISE FND_API.g_exc_unexpected_error;
                 END IF;
         ELSE
                 FND_MESSAGE.set_name('AMS', 'AMS_CAMP_UPDATE_SRC_STAT');
                 FND_MSG_PUB.add;
                 RAISE FND_API.g_exc_error;
         END IF;
      END IF;
   ELSIF  p_evh_rec.source_code IS NULL  /* added by musman for bug 2618242 fix*/
   THEN
      l_evh_rec.source_code := l_source_code;
   END IF;

   IF  p_evh_rec.global_flag <> FND_API.g_miss_char
   OR p_evh_rec.global_flag is NULL
   THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message('global_flag = ' || p_evh_rec.global_flag);
      END IF;

      IF p_evh_rec.global_flag <> l_global_flag
      THEN
         IF l_evh_rec.event_level = 'MAIN'
         AND l_evh_rec.system_status_code  = 'NEW'
         -- commented by musman oct 10
         --( OR l_evh_rec.system_status_code = 'PLANNING') since the source code canbe update only in new status
         THEN
                 -- extracting out source code modified by soagrawa
                 -- 21-jan-2003 bug# 2761612
                 AMS_EvhRules_PVT.update_evh_source_code(
                         l_evh_rec.event_header_id,
                         l_evh_rec.source_code,
                         l_evh_rec.global_flag,
                         l_dummy_source_code,
                         l_return_status
                 );
                 l_evh_rec.source_code := l_dummy_source_code;
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                         RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                         RAISE FND_API.g_exc_unexpected_error;
                 END IF;
         ELSE
                 FND_MESSAGE.set_name('AMS', 'AMS_EVNT_UPDATE_GFLG_STAT');
                 FND_MSG_PUB.add;
                 RAISE FND_API.g_exc_error;
         END IF;
      END IF;
   END IF;
   --------------- CHECK ACCESS FOR THE USER-------------------
   ----------added sugupta 07/25/2000
   l_user_id := FND_GLOBAL.User_Id;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(' CHECK ACCESS l_user_id is ' ||l_user_id );
   END IF;
   if l_user_id IS NOT NULL then
           open get_res_id(l_user_id);
           fetch get_res_id into l_res_id;
           close get_res_id;
   end if;
   IF l_evh_rec.event_level = 'SUB' THEN
           l_hdr_id := l_evh_rec.parent_event_header_id;
   ELSE
           l_hdr_id := l_evh_rec.event_header_id;
   END IF;

   if AMS_ACCESS_PVT.check_update_access(l_hdr_id, 'EVEH', l_res_id, 'USER') = 'N' then
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS');-- reusing the message
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   end if;

     -- ==========================================================
     -- Following code is added by mukumar on 10/30/2000
     -- the code will convert the transaction currency in to
     -- functional currency.
     -- ==========================================================
     IF p_evh_rec.fund_amount_tc IS NOT NULL THEN
        IF p_evh_rec.fund_amount_tc <> FND_API.g_miss_num THEN
           AMS_EvhRules_PVT.Convert_Evnt_Currency(
              p_tc_curr     => l_evh_rec.currency_code_tc,
              p_tc_amt      => l_evh_rec.fund_amount_tc,
              x_fc_curr     => l_evh_rec.currency_code_fc,
              x_fc_amt      => l_evh_rec.fund_amount_fc
           ) ;
        END IF ;
     ELSE
        l_evh_rec.fund_amount_fc := null ;
     END IF;

     /* Code Added by GMADANA for checking whether parent is active or not */

     Check_Parent_Active(
         p_evh_rec    => l_evh_rec,
         x_return_status      => x_return_status
      );

      IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                   RAISE Fnd_Api.g_exc_unexpected_error;
           ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
                   RAISE Fnd_Api.g_exc_error;
      END IF;


   /* Code Added by GMADANA for Date validation for attaching Program as Parent */
   /* Check_Dates_Range has date validation for MAIN level  as agenda for Event Header
      has no dates on the GUI.
   */

   IF (l_evh_rec.event_level = 'MAIN') THEN
     Check_Dates_Range(
         p_evh_rec    => l_evh_rec,
         x_return_status   => x_return_status
      );

      IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                   RAISE Fnd_Api.g_exc_unexpected_error;
           ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
                   RAISE Fnd_Api.g_exc_error;
      END IF;
        END IF;

    /* Call to Metrics If Progam name has chnaged */
   Update_Metrics (
            p_evh_rec => l_evh_rec,
       x_return_status  => x_return_status,
       x_msg_count  => x_msg_count,
                 x_msg_data  =>x_msg_data
     );

    IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                   RAISE Fnd_Api.g_exc_unexpected_error;
         ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
                   RAISE Fnd_Api.g_exc_error;
    END IF;


   /* If the owner user id cahnges call AMS_EvhRules_PVT.Update_Owner */
    -- Change the owner in Access table if the owner is changed.

   IF  p_evh_rec.owner_user_id <> FND_API.g_miss_num
   THEN
      AMS_EvhRules_PVT.Update_Owner(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_object_type       => 'EVEH',
           p_event_id          => l_evh_rec.event_header_id,
           p_owner_id          => p_evh_rec.owner_user_id
           );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF ;

   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;

-- GDEODHAR : Sept. 26, 2000 added two separate update statements.
-- One for the main events where the workflow has to be kicked off for status change
-- and hence the update of the base table should not update the status related fields.
-- The other update statement is needed for the Agenda items for which the status change
-- is straight-forward.

   IF  l_evh_rec.event_level = 'MAIN' THEN

   UPDATE ams_event_headers_all_b SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = l_evh_rec.object_version_number + 1,
      application_id = l_evh_rec.application_id,
      event_type_code = l_evh_rec.event_type_code,
      source_code = l_evh_rec.source_code,
      active_flag = l_evh_rec.active_flag,
      private_flag = l_evh_rec.private_flag,
      stream_type_code = l_evh_rec.stream_type_code,
      event_standalone_flag = l_evh_rec.event_standalone_flag,
      day_of_event = l_evh_rec.day_of_event,
          agenda_start_time = to_date((to_char(l_evh_rec.agenda_start_time,'HH24:MI')),'HH24:MI'),
          agenda_end_time = to_date((to_char(l_evh_rec.agenda_end_time,'HH24:MI')),'HH24:MI'),
      reg_required_flag = l_evh_rec.reg_required_flag,
      reg_charge_flag = l_evh_rec.reg_charge_flag,
      reg_invited_only_flag = l_evh_rec.reg_invited_only_flag,
      partner_flag = l_evh_rec.partner_flag,
      overflow_flag = l_evh_rec.overflow_flag,
      parent_event_header_id = l_evh_rec.parent_event_header_id,
      duration = l_evh_rec.duration,
      duration_uom_code = l_evh_rec.duration_uom_code,
      active_from_date = l_evh_rec.active_from_date,
      active_to_date = l_evh_rec.active_to_date,
      reg_maximum_capacity = l_evh_rec.reg_maximum_capacity,
      reg_minimum_capacity = l_evh_rec.reg_minimum_capacity,
      main_language_code = l_evh_rec.main_language_code,
      cert_credit_type_code = l_evh_rec.cert_credit_type_code,
      certification_credits = l_evh_rec.certification_credits,
      organization_id = l_evh_rec.organization_id,                              -- check if update is allowed on this field.
      inventory_item_id = l_evh_rec.inventory_item_id,                  -- check if update is allowed on this field.
      forecasted_revenue = l_evh_rec.forecasted_revenue,
      actual_revenue = l_evh_rec.actual_revenue,
      forecasted_cost = l_evh_rec.forecasted_cost,
      actual_cost = l_evh_rec.actual_cost,
      coordinator_id = l_evh_rec.coordinator_id,
      fund_source_type_code = l_evh_rec.fund_source_type_code,
      fund_source_id = l_evh_rec.fund_source_id,
      fund_amount_tc = l_evh_rec.fund_amount_tc,
      fund_amount_fc = l_evh_rec.fund_amount_fc,
      currency_code_tc = l_evh_rec.currency_code_tc,
      currency_code_fc = l_evh_rec.currency_code_fc,
      owner_user_id = l_evh_rec.owner_user_id,
      url = l_evh_rec.url,
      phone = l_evh_rec.phone,
      email = l_evh_rec.email,
      priority_type_code = l_evh_rec.priority_type_code,
      cancellation_reason_code = l_evh_rec.cancellation_reason_code,
      inbound_script_name = l_evh_rec.inbound_script_name,
      attribute_category = l_evh_rec.attribute_category,
      attribute1 = l_evh_rec.attribute1,
      attribute2 = l_evh_rec.attribute2,
      attribute3 = l_evh_rec.attribute3,
      attribute4 = l_evh_rec.attribute4,
      attribute5 = l_evh_rec.attribute5,
      attribute6 = l_evh_rec.attribute6,
      attribute7 = l_evh_rec.attribute7,
      attribute8 = l_evh_rec.attribute8,
      attribute9 = l_evh_rec.attribute9,
      attribute10 = l_evh_rec.attribute10,
      attribute11 = l_evh_rec.attribute11,
      attribute12 = l_evh_rec.attribute12,
      attribute13 = l_evh_rec.attribute13,
      attribute14 = l_evh_rec.attribute14,
      attribute15 = l_evh_rec.attribute15,
          country_code = l_evh_rec.country_code,
          business_unit_id = l_evh_rec.business_unit_id,
          event_calendar  = l_evh_rec.event_calendar,
          start_period_name = l_evh_rec.start_period_name,
          end_period_name = l_evh_rec.end_period_name,
          global_flag = nvl(l_evh_rec.global_flag, 'N'),
          task_id = l_evh_rec.task_id,
          program_id = l_evh_rec.program_id
         ,CREATE_ATTENDANT_LEAD_FLAG = l_evh_rec.CREATE_ATTENDANT_LEAD_FLAG /*hornet*/
         ,CREATE_REGISTRANT_LEAD_FLAG = l_evh_rec.CREATE_REGISTRANT_LEAD_FLAG /*hornet*/
         ,EVENT_PURPOSE_CODE = l_evh_rec.EVENT_PURPOSE_CODE /*hornet*/
   WHERE event_header_id = l_evh_rec.event_header_id
   AND object_version_number = l_evh_rec.object_version_number;

   ELSIF l_evh_rec.event_level = 'SUB' THEN

   UPDATE ams_event_headers_all_b SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = l_evh_rec.object_version_number + 1,
      application_id = l_evh_rec.application_id,
      event_type_code = l_evh_rec.event_type_code,
          source_code = l_evh_rec.source_code,
      active_flag = l_evh_rec.active_flag,
      private_flag = l_evh_rec.private_flag,
      user_status_id = l_evh_rec.user_status_id,
      system_status_code = l_evh_rec.system_status_code,
      last_status_date = l_evh_rec.last_status_date,
      stream_type_code = l_evh_rec.stream_type_code,
      event_standalone_flag = l_evh_rec.event_standalone_flag,
      day_of_event = l_evh_rec.day_of_event,
          agenda_start_time = to_date((to_char(l_evh_rec.agenda_start_time,'HH24:MI')),'HH24:MI'),
          agenda_end_time = to_date((to_char(l_evh_rec.agenda_end_time,'HH24:MI')),'HH24:MI'),
      reg_required_flag = l_evh_rec.reg_required_flag,
      reg_charge_flag = l_evh_rec.reg_charge_flag,
      reg_invited_only_flag = l_evh_rec.reg_invited_only_flag,
      partner_flag = l_evh_rec.partner_flag,
      overflow_flag = l_evh_rec.overflow_flag,
      parent_event_header_id = l_evh_rec.parent_event_header_id,
      duration = l_evh_rec.duration,
      duration_uom_code = l_evh_rec.duration_uom_code,
      active_from_date = l_evh_rec.active_from_date,
      active_to_date = l_evh_rec.active_to_date,
      reg_maximum_capacity = l_evh_rec.reg_maximum_capacity,
      reg_minimum_capacity = l_evh_rec.reg_minimum_capacity,
      main_language_code = l_evh_rec.main_language_code,
      cert_credit_type_code = l_evh_rec.cert_credit_type_code,
      certification_credits = l_evh_rec.certification_credits,
      organization_id = l_evh_rec.organization_id,                              -- check if update is allowed on this field.
      inventory_item_id = l_evh_rec.inventory_item_id,                  -- check if update is allowed on this field.
      forecasted_revenue = l_evh_rec.forecasted_revenue,
      actual_revenue = l_evh_rec.actual_revenue,
      forecasted_cost = l_evh_rec.forecasted_cost,
      actual_cost = l_evh_rec.actual_cost,
      coordinator_id = l_evh_rec.coordinator_id,
      fund_source_type_code = l_evh_rec.fund_source_type_code,
      fund_source_id = l_evh_rec.fund_source_id,
      fund_amount_tc = l_evh_rec.fund_amount_tc,
      fund_amount_fc = l_evh_rec.fund_amount_fc,
      currency_code_tc = l_evh_rec.currency_code_tc,
      currency_code_fc = l_evh_rec.currency_code_fc,
      owner_user_id = l_evh_rec.owner_user_id,
      url = l_evh_rec.url,
      phone = l_evh_rec.phone,
      email = l_evh_rec.email,
      priority_type_code = l_evh_rec.priority_type_code,
      cancellation_reason_code = l_evh_rec.cancellation_reason_code,
      inbound_script_name = l_evh_rec.inbound_script_name,
      attribute_category = l_evh_rec.attribute_category,
      attribute1 = l_evh_rec.attribute1,
      attribute2 = l_evh_rec.attribute2,
      attribute3 = l_evh_rec.attribute3,
      attribute4 = l_evh_rec.attribute4,
      attribute5 = l_evh_rec.attribute5,
      attribute6 = l_evh_rec.attribute6,
      attribute7 = l_evh_rec.attribute7,
      attribute8 = l_evh_rec.attribute8,
      attribute9 = l_evh_rec.attribute9,
      attribute10 = l_evh_rec.attribute10,
      attribute11 = l_evh_rec.attribute11,
      attribute12 = l_evh_rec.attribute12,
      attribute13 = l_evh_rec.attribute13,
      attribute14 = l_evh_rec.attribute14,
      attribute15 = l_evh_rec.attribute15,
          country_code = l_evh_rec.country_code,
          business_unit_id = l_evh_rec.business_unit_id,
          event_calendar  = l_evh_rec.event_calendar,
          start_period_name = l_evh_rec.start_period_name,
          end_period_name = l_evh_rec.end_period_name,
          global_flag = nvl(l_evh_rec.global_flag, 'N')
   WHERE event_header_id = l_evh_rec.event_header_id
   AND object_version_number = l_evh_rec.object_version_number;

   END IF;

-- GDEODHAR : End of changes. Sept. 26th 2000.

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': update done');

   END IF;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||':BEFORE TL');

   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('FOR NAGEN : Before Update evhname = ' || l_evh_rec.event_header_name);
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('FOR NAGEN : Before Update evhdesc = ' || l_evh_rec.description);
   END IF;

-- GDEODHAR : Sept. 26th, 2000 : Note that for MAIN Events and Agenda (SUB) items, the
-- update of the TL table is the same.

   update ams_event_headers_all_tl set
      event_header_name = l_evh_rec.event_header_name,
      event_mktg_message = l_evh_rec.event_mktg_message,
      description = l_evh_rec.description,
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE event_header_id = l_evh_rec.event_header_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||':AFTER TL');

   END IF;

---murali call "update_event_status 09/26/00 S
-- GDEODHAR : Added a condition. (Sept. 26th 2000)

   IF l_evh_rec.event_level = 'MAIN' THEN
           AMS_EvhRules_PVT.update_event_status(
                                           p_event_id => l_evh_rec.event_header_id,
                                           p_event_activity_type => 'EVEH',
                                           p_user_status_id => l_evh_rec.user_status_id,
                                           p_fund_amount_tc => l_evh_rec.fund_amount_tc,
                                           p_currency_code_tc => l_evh_rec.currency_code_tc
                                          );
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message('calling before Add_Update_Access_record');
        END IF;
        AMS_EvhRules_PVT.Add_Update_Access_record(p_object_type => 'EVEH',
                                                  p_object_id => l_evh_rec.event_header_id,
                                                  p_Owner_user_id => l_evh_rec.owner_user_id,
                                                  x_return_status => l_return_status,
                                                  x_msg_count          => x_msg_count,
                                                 x_msg_data           => x_msg_data);
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_Utility_PVT.debug_message('after  before Add_Update_Access_record || l_return_status');
        END IF;
   END IF;
---murali call "update_event_status 09/26/00 E


   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
          IF (AMS_DEBUG_HIGH_ON) THEN

              AMS_Utility_PVT.debug_message(l_full_name ||':Calling Commit.');
          END IF;
      COMMIT;
   ELSE
          IF (AMS_DEBUG_HIGH_ON) THEN

              AMS_Utility_PVT.debug_message(l_full_name ||':Did not call Commit.');
          END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': getting messages');

   END IF;

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
      ROLLBACK TO update_event_header;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_event_header;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_event_header;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END update_event_header;


--------------------------------------------------------------------
-- PROCEDURE
--    validate_event_header
--
-- HISTORY
--    11/17/1999  gdeodhar  Created.
--------------------------------------------------------------------
PROCEDURE validate_event_header(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec          IN  evh_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_event_header';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
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

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_evh_items(
         p_evh_rec        => p_evh_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name||': check record');

   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_evh_record(
         p_evh_rec       => p_evh_rec,
         p_complete_rec   => NULL,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   IF (AMS_DEBUG_HIGH_ON) THEN





       AMS_Utility_PVT.debug_message(l_full_name||': check inter-entity');


   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_inter_entity THEN
     IF p_evh_rec.event_level = 'MAIN' THEN
      check_evh_inter_entity(
         p_evh_rec        => p_evh_rec,
         p_complete_rec    => p_evh_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
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

END validate_event_header;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_update_ok_items
--
-- HISTORY
--    11/18/1999  gdeodhar  Created.
---------------------------------------------------------------------
PROCEDURE check_evh_update_ok_items(
   p_evh_rec        IN  evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Which validations should go here?
   -- must check with Ravi.

END check_evh_update_ok_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_req_items
--
-- HISTORY
--    11/17/1999  gdeodhar  Created.
--    11/19/1999  rvaka     updated.
--
--
-- NOTES
--        not checking all flags and  last_status_date as they are defaulted
---------------------------------------------------------------------
PROCEDURE check_evh_req_items(
   p_evh_rec       IN  evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('INSIDE EVH REQ');
   END IF;

   ------------------------ owner_user_id --------------------------
   IF p_evh_rec.owner_user_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVH_NO_OWNER_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- user_status_id cannot be made as a required field.
   -- it is defaulted to 1 (i.e NEW) in create.
   -- sometimes it is sent by update, however mostly it is driven
   -- by the status order rules and updated through workflow.

   ------------------------ event_type_code --------------------
   -------------------- required only for MAIN event_level------
   IF p_evh_rec.event_level = 'MAIN' AND
      p_evh_rec.event_type_code IS NULL THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVH_NO_EVENT_TYPE_CODE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;

   END IF;
   ------------------------ event_level --------------------------
   IF p_evh_rec.event_level IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVH_NO_EVENT_LEVEL');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   ------------------------ event_header_name --------------------------
   IF p_evh_rec.event_header_name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVH_NO_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   ------------------------ application_id --------------------------
   IF p_evh_rec.application_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_NO_APPLICATION_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   ------------------------ custom_setup_id --------------------------
   IF (p_evh_rec.event_level = 'MAIN' AND
                (p_evh_rec.custom_setup_id IS NULL OR p_evh_rec.custom_setup_id = FND_API.g_miss_num)) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_SETUP_ID'); -- this message is generic enuf for EVO or EVH
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   -- check other required items.
   -- if duration is not null, duration uom code must be present and vice-versa.


END check_evh_req_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_uk_items
--
-- HISTORY
--    11/17/1999  gdeodhar  Created.
--    11/19/1999  rvaka  updated.
---------------------------------------------------------------------
PROCEDURE check_evh_uk_items(
   p_evh_rec        IN  evh_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS


   l_valid_flag  VARCHAR2(1);
   l_dummy   NUMBER;
   cursor c_src_code(src_code_in IN VARCHAR2) IS
   SELECT 1 FROM DUAL WHERE EXISTS (select 1 from ams_source_codes
                          where SOURCE_CODE = src_code_in);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message('INSIDE EVH UK');

   END IF;

   -- For create_event_header, when event_header_id is passed in, we need to
   -- check if this event_header_id is unique.

   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_evh_rec.event_header_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
                      'ams_event_headers_vl',
                                'event_header_id = ' || p_evh_rec.event_header_id
                        ) = FND_API.g_false
                THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                        THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- For create_event_header, when source_code is passed in, we need to
   -- check if this source_code is unique.
   -- For creating, check if source_code is unique in ams_source_codes.
   -- Update of source_code is not allowed.
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_evh_rec.source_code IS NOT NULL THEN
         /*
         IF AMS_Utility_PVT.check_uniqueness(
               'ams_source_codes',
               'source_code = ''' || p_evh_rec.source_code ||''''
            ) = FND_API.g_false
       */
         open c_src_code(p_evh_rec.source_code);
         fetch c_src_code into l_dummy;
         close c_src_code;
         IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_UTILITY_PVt.debug_message('the value of l_dummy is '||l_dummy);
         END IF;
         IF l_dummy = 1
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVH_DUPLICATE_SOURCE_CODE');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
         /* source code should not be passed from screen and it can never be updated
         will not complete source code column in complete_evh_rec and will not
         update this column in update sql stmt
         CHANGE OF LOGIC: SOURCE CODE CAN BE PASSED FROM SCREEN
                WILL BE COMPLETED IN COMPLETE_EVH_REC AND WILL BE UPDATED
                UNDER EVENTRULES_API, WILL CHECK FOR UNIQUENESS OF SOURCE CODE PASSED AND REVOKE OLD CODE AND CREATE NEW ONE
                IF NECESSARY.
        HOWEVER, SOURCE CODE CANNOT BE CHANGED IF STATUS <> NEW... CHECKED IN BUSINESS RULES AS WELL...

   ELSIF p_evh_rec.source_code <> FND_API.g_miss_char THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVH_CANT_UPD_SRCCODE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
        */
   END IF;

   -- check other unique items

END check_evh_uk_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_fk_items
--
-- HISTORY
--    11/17/1999  gdeodhar  Created.
---------------------------------------------------------------------
PROCEDURE check_evh_fk_items(
   p_evh_rec        IN  evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                NUMBER;
   l_additional_where_clause     VARCHAR2(4000);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_Utility_PVT.debug_message('CC' ||':INSIDE EVH FK');

END IF;
   ----------------------- owner_user_id ------------------------
   IF p_evh_rec.owner_user_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_jtf_rs_emp_v',
            'resource_id',
            p_evh_rec.owner_user_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_OWNER_USER_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   --------------------- application_id ------------------------
   IF p_evh_rec.application_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_application',
            'application_id',
            p_evh_rec.application_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_APPLICATION_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- inbound_script_name ------------------------
   IF p_evh_rec.inbound_script_name <> FND_API.g_miss_char
      AND p_evh_rec.inbound_script_name IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ies_deployed_scripts',
            'dscript_name',
            p_evh_rec.inbound_script_name,
            AMS_Utility_PVT.g_varchar2
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_INBOUND_SCRIPT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- parent_event_header_id ------------------------
   IF p_evh_rec.parent_event_header_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_event_headers_vl',
            'event_header_id',
            p_evh_rec.parent_event_header_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_PARENT_EVEH');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

      ----------------------- program_id ------------------------
   IF p_evh_rec.program_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'AMS_CAMPAIGNS_ALL_B',
            'CAMPAIGN_ID',
            p_evh_rec.program_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_PARENT_EVEH');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- currency_code_tc ------------------------
   IF p_evh_rec.currency_code_tc <> FND_API.g_miss_char
      AND p_evh_rec.currency_code_tc IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_currencies_vl',
            'currency_code',
            p_evh_rec.currency_code_tc,
            AMS_Utility_PVT.g_varchar2
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_CURRENCY_CODE_TC');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- currency_code_fc ------------------------
   IF p_evh_rec.currency_code_fc <> FND_API.g_miss_char
      AND p_evh_rec.currency_code_fc IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_currencies_vl',
            'currency_code',
            p_evh_rec.currency_code_fc,
                AMS_Utility_PVT.g_varchar2
           ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_CURRENCY_CODE_FC');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
      ----------------------- user_status_id ------------------------
   IF p_evh_rec.user_status_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_user_statuses_b',
            'user_status_id',
            p_evh_rec.user_status_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_USER_STATUS_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   --------------------- country_code ----------------------------
/*   Since from hornet country code contains country id  we need to rplace the old validation with new
   validation the followinfg is the new valiation
*/
   IF p_evh_rec.country_code <> FND_API.g_miss_char AND
      p_evh_rec.country_code IS NOT NULL THEN

      l_table_name              := 'jtf_loc_hierarchies_b';
      l_pk_name                 := 'location_hierarchy_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := to_number(p_evh_rec.country_code);
      l_additional_where_clause := null ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_COUNTRY') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

/*  old code
   IF p_evh_rec.country_code <> FND_API.g_miss_char
      AND p_evh_rec.country_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_territories_vl',
            'territory_code',
            p_evh_rec.country_code,
            AMS_Utility_PVT.g_varchar2,
            NULL
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CAMP_BAD_CITY');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
   -- check other fk items
   -- no need to check system_status_code as we are
-- storing it in the header table just to ease the reporting.

END check_evh_fk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_lookup_items
--
-- HISTORY
--    11/18/1999  gdeodhar  Created.
---------------------------------------------------------------------
PROCEDURE check_evh_lookup_items(
   p_evh_rec        IN  evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message('INSIDE EVH LOOKUP');
      END IF;

/*
   ----------------------- system_status_code ------------------------
   IF p_evh_rec.system_status_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
                p_lookup_table_name => 'AMS_USER_STATUSES_B',
            p_lookup_type => 'AMS_EVENT_STATUS',
            p_lookup_code => p_evh_rec.system_status_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_STATUS_CODE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Note: it may not be necessary to check the system_status_code in this procedure.
   -- we are storing this field in headers table just for ease of reporting.
   */

   -- check other lookup codes
   -- event_level must be checked here. (MAIN or SUB)

   ----------------------- event_type ------------------------
   IF p_evh_rec.event_type_code <> FND_API.g_miss_char
      AND p_evh_rec.event_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_TYPE',
            p_lookup_code => p_evh_rec.event_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

     ----------------------- event_level ------------------------
   IF p_evh_rec.event_level <> FND_API.g_miss_char
      AND p_evh_rec.event_level IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_LEVEL',
            p_lookup_code => p_evh_rec.event_level
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_EVENT_LEVEL');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- priority ------------------------
   IF p_evh_rec.priority_type_code <> FND_API.g_miss_char
      AND p_evh_rec.priority_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_PRIORITY',
            p_lookup_code => p_evh_rec.priority_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_PRIORITY');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   ----------------------- fund_source_type ------------------------
   IF p_evh_rec.fund_source_type_code <> FND_API.g_miss_char
      AND p_evh_rec.fund_source_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_FUND_SOURCE',
            p_lookup_code => p_evh_rec.fund_source_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_FUND_SOURCE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- day_of_event ------------------------
   IF p_evh_rec.day_of_event <> FND_API.g_miss_char
      AND p_evh_rec.day_of_event IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_DAY',
            p_lookup_code => p_evh_rec.day_of_event
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_DAY_OF_EVENT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- certification_credit_type ------------------------
   IF p_evh_rec.cert_credit_type_code <> FND_API.g_miss_char
      AND p_evh_rec.cert_credit_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_CERT_CREDIT_TYPE',
            p_lookup_code => p_evh_rec.cert_credit_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_CERT_CREDIT_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- cancellation_reason_code ------------------------
   IF p_evh_rec.cancellation_reason_code <> FND_API.g_miss_char
      AND p_evh_rec.cancellation_reason_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_CANCEL_REASON',
            p_lookup_code => p_evh_rec.cancellation_reason_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_CANCEL_REASON');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- stream_type_code ------------------------
   IF p_evh_rec.stream_type_code <> FND_API.g_miss_char
      AND p_evh_rec.stream_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_STREAM_TYPE',
            p_lookup_code => p_evh_rec.stream_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_STREAM_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

       IF (AMS_DEBUG_HIGH_ON) THEN



           AMS_Utility_PVT.debug_message('AFTER EVH LOOKUP');

       END IF;


END check_evh_lookup_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_flag_items
--
-- HISTORY
--    11/18/1999  gdeodhar  Created
--    11/19/1999  rvaka     updated
---------------------------------------------------------------------
PROCEDURE check_evh_flag_items(
   p_evh_rec        IN  evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('INSIDE EVH FLAG');
   END IF;

   ----------------------- active_flag ------------------------
   IF p_evh_rec.active_flag <> FND_API.g_miss_char
      AND p_evh_rec.active_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evh_rec.active_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_ACTIVE_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- event_standalone_flag ------------------------
   IF p_evh_rec.event_standalone_flag <> FND_API.g_miss_char
      AND p_evh_rec.event_standalone_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evh_rec.event_standalone_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_STANDALONE_FL');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- private_flag ------------------------
   IF p_evh_rec.private_flag <> FND_API.g_miss_char
      AND p_evh_rec.private_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evh_rec.private_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_PRIVATE_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- reg_required_flag ------------------------
   IF p_evh_rec.reg_required_flag <> FND_API.g_miss_char
      AND p_evh_rec.reg_required_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evh_rec.reg_required_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_REG_REQUIRED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- reg_invited_only_flag ------------------------
   IF p_evh_rec.reg_invited_only_flag <> FND_API.g_miss_char
      AND p_evh_rec.reg_invited_only_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evh_rec.reg_invited_only_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_REG_INV_ONLY');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

      ----------------------- reg_charge_flag ------------------------
   IF p_evh_rec.reg_charge_flag <> FND_API.g_miss_char
      AND p_evh_rec.reg_charge_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evh_rec.reg_charge_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_REG_CHARGE_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   ----------------------- overflow_flag ------------------------
   IF p_evh_rec.overflow_flag <> FND_API.g_miss_char
      AND p_evh_rec.overflow_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evh_rec.overflow_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_OVERFLOW_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- check other flags
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message('AFTER EVH FLAG');
      END IF;


END check_evh_flag_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_items
--
-- HISTORY
--    11/18/1999  gdeodhar  Created.
--    12/18/1999  rvaka  updated.
---------------------------------------------------------------------
PROCEDURE check_evh_items(
   p_evh_rec         IN  evh_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('INSIDE EVH ITEMS');
   END IF;
   -------------------------- Update Mode ----------------------------
   -- check if the p_evh_rec has any columns that should not be updated at this stage as per the business logic.
   -- Also when the event is in active stage (will add later)
   --changes to marketing message and budget related columns should not be allowed.

   IF p_validation_mode = JTF_PLSQL_API.g_update THEN
          check_evh_update_ok_items(
                p_evh_rec        => p_evh_rec,
                x_return_status  => x_return_status
          );

          IF x_return_status <> FND_API.g_ret_sts_success THEN
                RETURN;
          END IF;
    END IF;

   -------------------------- Create or Update Mode ----------------------------

   check_evh_req_items(
      p_evh_rec        => p_evh_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_evh_uk_items(
      p_evh_rec         => p_evh_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_evh_fk_items(
      p_evh_rec        => p_evh_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_evh_lookup_items(
      p_evh_rec         => p_evh_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_evh_flag_items(
      p_evh_rec         => p_evh_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END check_evh_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_record
--
-- HISTORY
--    11/18/1999  gdeodhar  Created.
--    12/18/1999  rvaka  updated.
---------------------------------------------------------------------
PROCEDURE check_evh_record(
   p_evh_rec        IN  evh_rec_type,
   p_complete_rec   IN  evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   l_start_date  DATE := p_evh_rec.active_from_date;
   l_end_date    DATE := p_evh_rec.active_to_date;
   l_start_time  DATE := p_evh_rec.agenda_start_time;
   l_end_time    DATE := p_evh_rec.agenda_end_time;

BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('INSIDE EVH RECORD');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;


  IF p_evh_rec.active_from_date = FND_API.g_miss_date THEN
      l_start_date := p_complete_rec.active_from_date;
   ELSE
      l_start_date := p_evh_rec.active_from_date;
   END IF;

   IF p_evh_rec.active_to_date = FND_API.g_miss_date THEN
      l_end_date := p_complete_rec.active_to_date;
   ELSE
      l_end_date := p_evh_rec.active_to_date;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message('L_ST_DATE:'||to_char(l_start_date,'DD-MON-YYY'));

   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('L_END_DATE:'||to_char(l_end_date,'DD-MON-YYY'));
   END IF;

   IF (l_start_date > l_end_date) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVH_START_DT_GT_END_DT');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RAISE Fnd_Api.g_exc_error;
      return;
    END IF;

  /* Code Added by GMADANA
     Agenda Start time and Agenda End Time are present only for those with event level = 'SUB'
  */

   IF  p_complete_rec.event_level = 'SUB' THEN
         IF p_evh_rec.agenda_start_time = Fnd_Api.g_miss_date THEN
            l_start_time := p_complete_rec.agenda_start_time;
         ELSE
            l_start_time := p_evh_rec.agenda_start_time;
         END IF;

         IF p_evh_rec.agenda_end_time = Fnd_Api.g_miss_date THEN
            l_end_time := p_complete_rec.agenda_end_time;
         ELSE
            l_end_time := p_evh_rec.agenda_end_time;
         END IF;

      IF l_start_time > l_end_time THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVO_START_TM_GT_END_TM'); -- reusing EVEO message
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RAISE Fnd_Api.g_exc_error;
            return;
      END IF; -- st tm > end tm
  END IF; -- event_level = 'SUB'

   -- Check if the above logic will work if either of the dates are NULL.

IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_Utility_PVT.debug_message('p_complete_rec.DURATION:'||p_complete_rec.DURATION);

END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message('p_evh_rec.DURATION:'||p_evh_rec.DURATION);
END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message('p_complete_rec.DURATION_UOM_CODE:'||nvl(p_complete_rec.DURATION_UOM_CODE,'NULL'));
END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message('p_evh_rec.DURATION_UOM_CODE:'||nvl(p_evh_rec.DURATION_UOM_CODE, 'NULL') );
END IF;

   -- do other record level checkings
   IF (p_evh_rec.DURATION <> FND_API.g_miss_num
    AND p_evh_rec.DURATION IS NOT NULL )
        OR p_complete_rec.DURATION IS NOT NULL THEN

        IF (p_evh_rec.DURATION_UOM_CODE = FND_API.g_miss_char
                AND p_complete_rec.DURATION_UOM_CODE IS NULL)
                OR p_evh_rec.DURATION_UOM_CODE IS NULL
                 THEN
                        AMS_Utility_PVT.error_message('AMS_EVO_NO_DUR_UOM_CODE');
                        x_return_status := FND_API.g_ret_sts_error;
                        return;
        END IF;
 END IF;

 IF (p_evh_rec.DURATION_UOM_CODE <> FND_API.g_miss_char
     AND  p_evh_rec.DURATION_UOM_CODE IS NOT NULL)
        OR p_complete_rec.DURATION_UOM_CODE IS NOT NULL THEN

        IF (p_evh_rec.DURATION = FND_API.g_miss_num
                AND p_complete_rec.DURATION IS NULL)
                OR p_evh_rec.DURATION IS NULL
                THEN
                        AMS_Utility_PVT.error_message('AMS_EVO_NO_DUR_WITH_CODE');
                        x_return_status := FND_API.g_ret_sts_error;
                        return;
        END IF;
 END IF;
-- added sugupta 07/20/2000 if budget amount's there, there has to be currency code
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message('p_complete_rec.FUND_AMOUNT_TC:'||p_complete_rec.FUND_AMOUNT_TC);
END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message('p_evh_rec.FUND_AMOUNT_TC:'||p_evh_rec.FUND_AMOUNT_TC);
END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message('p_complete_rec.CURRENCY_CODE_TC:'||nvl(p_complete_rec.CURRENCY_CODE_TC,'NULL'));
END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message('p_evh_rec.CURRENCY_CODE_TC:'||nvl(p_evh_rec.CURRENCY_CODE_TC, 'NULL') );
END IF;
 IF p_evh_rec.FUND_AMOUNT_TC <> FND_API.g_miss_num
        OR p_complete_rec.FUND_AMOUNT_TC IS NOT NULL THEN

        IF p_evh_rec.CURRENCY_CODE_TC = FND_API.g_miss_char
                AND p_complete_rec.CURRENCY_CODE_TC IS NULL THEN
                        AMS_Utility_PVT.error_message('AMS_CAMP_BUDGET_NO_CURRENCY'); -- reusing campaign message
                        x_return_status := FND_API.g_ret_sts_error;
                        return;
        END IF;
 END IF;


END check_evh_record;


---------------------------------------------------------------------
-- PROCEDURE
--    init_evh_rec
--
-- HISTORY
--    11/18/1999  gdeodhar  Created.
--    12/18/1999  rvaka  updated.
---------------------------------------------------------------------
PROCEDURE init_evh_rec(
   x_evh_rec  OUT NOCOPY  evh_rec_type
)
IS
BEGIN

        x_evh_rec.event_header_id := FND_API.g_miss_num;
        x_evh_rec.last_update_date := FND_API.g_miss_date;
        x_evh_rec.last_updated_by := FND_API.g_miss_num;
        x_evh_rec.creation_date := FND_API.g_miss_date;
        x_evh_rec.created_by := FND_API.g_miss_num;
        x_evh_rec.last_update_login := FND_API.g_miss_num;
        x_evh_rec.object_version_number := FND_API.g_miss_num;
        x_evh_rec.event_level := FND_API.g_miss_char;
        x_evh_rec.application_id := FND_API.g_miss_num;
        x_evh_rec.event_type_code := FND_API.g_miss_char;
        x_evh_rec.active_flag := FND_API.g_miss_char;
        x_evh_rec.private_flag := FND_API.g_miss_char;
        x_evh_rec.user_status_id := FND_API.g_miss_num;
        x_evh_rec.system_status_code := FND_API.g_miss_char;
        x_evh_rec.last_status_date := FND_API.g_miss_date;
        x_evh_rec.stream_type_code := FND_API.g_miss_char;
        x_evh_rec.source_code := FND_API.g_miss_char;
        x_evh_rec.event_standalone_flag := FND_API.g_miss_char;
        x_evh_rec.day_of_event := FND_API.g_miss_char;
        x_evh_rec.agenda_start_time := FND_API.g_miss_date;
        x_evh_rec.agenda_end_time := FND_API.g_miss_date;
        x_evh_rec.reg_required_flag := FND_API.g_miss_char;
        x_evh_rec.reg_charge_flag := FND_API.g_miss_char;
        x_evh_rec.reg_invited_only_flag := FND_API.g_miss_char;
        x_evh_rec.partner_flag := FND_API.g_miss_char;
        x_evh_rec.overflow_flag := FND_API.g_miss_char;
        x_evh_rec.parent_event_header_id := FND_API.g_miss_num;
        x_evh_rec.duration := FND_API.g_miss_num;
        x_evh_rec.duration_uom_code := FND_API.g_miss_char;
        x_evh_rec.active_from_date := FND_API.g_miss_date;
        x_evh_rec.active_to_date := FND_API.g_miss_date;
        x_evh_rec.reg_maximum_capacity := FND_API.g_miss_num;
        x_evh_rec.reg_minimum_capacity := FND_API.g_miss_num;
        x_evh_rec.main_language_code := FND_API.g_miss_char;
        x_evh_rec.cert_credit_type_code := FND_API.g_miss_char;
        x_evh_rec.certification_credits := FND_API.g_miss_num;
        x_evh_rec.inventory_item_id := FND_API.g_miss_num;
        x_evh_rec.org_id := FND_API.g_miss_num;
        x_evh_rec.forecasted_revenue := FND_API.g_miss_num;
        x_evh_rec.actual_revenue := FND_API.g_miss_num;
        x_evh_rec.forecasted_cost := FND_API.g_miss_num;
        x_evh_rec.actual_cost := FND_API.g_miss_num;
        x_evh_rec.coordinator_id := FND_API.g_miss_num;
        x_evh_rec.fund_source_type_code := FND_API.g_miss_char;
        x_evh_rec.fund_source_id := FND_API.g_miss_num;
        x_evh_rec.fund_amount_tc := FND_API.g_miss_num;
        x_evh_rec.fund_amount_fc := FND_API.g_miss_num;
        x_evh_rec.currency_code_tc := FND_API.g_miss_char;
        x_evh_rec.currency_code_fc := FND_API.g_miss_char;
        x_evh_rec.owner_user_id := FND_API.g_miss_num;
        x_evh_rec.url := FND_API.g_miss_char;
        x_evh_rec.phone := FND_API.g_miss_char;
        x_evh_rec.email := FND_API.g_miss_char;
        x_evh_rec.priority_type_code := FND_API.g_miss_char;
        x_evh_rec.cancellation_reason_code := FND_API.g_miss_char;
        x_evh_rec.inbound_script_name := FND_API.g_miss_char;
        x_evh_rec.attribute_category := FND_API.g_miss_char;
        x_evh_rec.attribute1 := FND_API.g_miss_char;
        x_evh_rec.attribute2 := FND_API.g_miss_char;
        x_evh_rec.attribute3 := FND_API.g_miss_char;
        x_evh_rec.attribute4 := FND_API.g_miss_char;
        x_evh_rec.attribute5 := FND_API.g_miss_char;
        x_evh_rec.attribute6 := FND_API.g_miss_char;
        x_evh_rec.attribute7 := FND_API.g_miss_char;
        x_evh_rec.attribute8 := FND_API.g_miss_char;
        x_evh_rec.attribute9 := FND_API.g_miss_char;
        x_evh_rec.attribute10 := FND_API.g_miss_char;
        x_evh_rec.attribute11 := FND_API.g_miss_char;
        x_evh_rec.attribute12 := FND_API.g_miss_char;
        x_evh_rec.attribute13 := FND_API.g_miss_char;
        x_evh_rec.attribute14 := FND_API.g_miss_char;
        x_evh_rec.attribute15 := FND_API.g_miss_char;
        x_evh_rec.event_header_name := FND_API.g_miss_char;
        x_evh_rec.event_mktg_message := FND_API.g_miss_char;
        x_evh_rec.description := FND_API.g_miss_char;
    x_evh_rec.custom_setup_id := FND_API.g_miss_num;
        x_evh_rec.country_code := FND_API.g_miss_char;
        x_evh_rec.business_unit_id := FND_API.g_miss_num;
        x_evh_rec.event_calendar := FND_API.g_miss_char;
   x_evh_rec.start_period_name := FND_API.g_miss_char;
   x_evh_rec.end_period_name := FND_API.g_miss_char;
   x_evh_rec.global_flag := FND_API.g_miss_char;
   x_evh_rec.task_id := FND_API.g_miss_num;
   x_evh_rec.program_id := FND_API.g_miss_num;
   x_evh_rec.CREATE_ATTENDANT_LEAD_FLAG := FND_API.g_miss_char; /*hornet*/
   x_evh_rec.CREATE_REGISTRANT_LEAD_FLAG := FND_API.g_miss_char;/*hornet*/
   x_evh_rec.event_purpose_code := FND_API.g_miss_char;/* Hornet : added aug13*/

END init_evh_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_inter_entity
--
-- HISTORY
--
---------------------------------------------------------------------
PROCEDURE check_evh_inter_entity(
   p_evh_rec         IN  evh_rec_type,
   p_complete_rec    IN  evh_rec_type,
   p_validation_mode IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

   l_return_status  VARCHAR2(1);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ------------------- check fund source ----------------------
   -- no need to check for event_level=MAIN
   IF p_evh_rec.fund_source_type_code <> FND_API.g_miss_char
      OR p_evh_rec.fund_source_id <> FND_API.g_miss_num
   THEN
      AMS_EvhRules_PVT.check_evh_fund_source(
         p_complete_rec.fund_source_type_code,
         p_complete_rec.fund_source_id,
         l_return_status
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message('start_date' ||p_evh_rec.active_from_date);

   END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_Utility_PVT.debug_message('end_date' ||p_evh_rec.active_to_date);
 END IF;

   ------------------- check calendar ----------------------
   IF p_evh_rec.event_calendar <> FND_API.g_miss_char
      OR p_evh_rec.start_period_name <> FND_API.g_miss_char
      OR p_evh_rec.end_period_name <> FND_API.g_miss_char
      OR p_evh_rec.active_from_date <> FND_API.g_miss_date
      OR p_evh_rec.active_to_date <> FND_API.g_miss_date
   THEN
        AMS_EvhRules_PVT.check_evh_calendar(
         p_complete_rec.event_calendar,
         p_complete_rec.start_period_name,
         p_complete_rec.end_period_name,
         p_complete_rec.active_from_date,
         p_complete_rec.active_to_date,
         l_return_status
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;

      null;
   END IF;
   ------------------------------Source code-------------------
/*      IF ((p_evh_rec.source_code IS NOT NULL) AND (p_evh_rec.source_code <> p_complete_rec.source_code)) THEN
                IF AMS_Utility_PVT.check_uniqueness(
                                                        'ams_source_codes',
                                                        'source_code = ''' || p_evh_rec.source_code ||
                                                        ''' AND active_flag = ''Y'''
                                                        ) = FND_API.g_false
                THEN
                        AMS_Utility_PVT.Error_Message('AMS_CAMP_DUPLICATE_CODE');
                        x_return_status := FND_API.g_ret_sts_error;
                        RETURN;
                END IF;
        END IF;
*/
END check_evh_inter_entity;

---------------------------------------------------------------------
-- PROCEDURE
--    complete_evh_rec
--
-- HISTORY
--    11/18/1999  gdeodhar  Created.
---------------------------------------------------------------------
PROCEDURE complete_evh_rec(
   p_evh_rec       IN  evh_rec_type,
   x_complete_rec  OUT NOCOPY evh_rec_type
)
IS
   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'complete evh rec';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   x_msg_count number;
   x_msg_data varchar2(240);
   x_return_status varchar2(240);

   CURSOR c_evh IS
   SELECT *
     FROM ams_event_headers_vl
     WHERE event_header_id = p_evh_rec.event_header_id;

   l_evh_rec  c_evh%ROWTYPE;

-- modified sugupta 08/13/2000 since ams_event_headers_vl doesnt have setup_id, and dont want to
-- change odf files now.. add new cursor to get setup from table...
-- need to change ams_event_headers_vl later to include setup_id
   CURSOR c_setup IS
   select setup_type_id
   from ams_event_headers_all_b
   where event_header_id = p_evh_rec.event_header_id;

   l_setup NUMBER;

BEGIN
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_Utility_PVT.debug_message('compelte_evh' ||':inside compelte');
 END IF;
   x_complete_rec := p_evh_rec;

   OPEN c_evh;
   FETCH c_evh INTO l_evh_rec;
   IF c_evh%NOTFOUND THEN
      CLOSE c_evh;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_evh;

   OPEN c_setup;
   FETCH c_setup INTO l_setup;
   IF c_setup%NOTFOUND THEN
      CLOSE c_setup;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_setup;

   -- This procedure should complete the record by going through all the items in the incoming record.
   -- Somewhere it must be checked however if certain fields can be or cannot be updated by the user based on the status of the event.
   -- For example, if the event is in active stage, the user will not be able to update the Marketing Message or budget related columns.

  -- adding code to complete setup_type_id ( custom_setup_id in evo_rec)
   IF p_evh_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := l_setup;
   END IF;

   IF p_evh_rec.event_level = FND_API.g_miss_char THEN
      x_complete_rec.event_level := l_evh_rec.event_level;
   END IF;

   IF p_evh_rec.application_id = FND_API.g_miss_num THEN
      x_complete_rec.application_id := l_evh_rec.application_id;
   END IF;

   IF p_evh_rec.event_type_code = FND_API.g_miss_char THEN
      x_complete_rec.event_type_code := l_evh_rec.event_type_code;
   END IF;

   IF p_evh_rec.active_flag = FND_API.g_miss_char THEN
      x_complete_rec.active_flag := l_evh_rec.active_flag;
   END IF;

   IF p_evh_rec.private_flag = FND_API.g_miss_char THEN
      x_complete_rec.private_flag := l_evh_rec.private_flag;
   END IF;

   IF p_evh_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_evh_rec.user_status_id;
   END IF;

   IF p_evh_rec.system_status_code = FND_API.g_miss_char THEN
      x_complete_rec.system_status_code := l_evh_rec.system_status_code;
   END IF;

   IF p_evh_rec.last_status_date = FND_API.g_miss_date
      OR p_evh_rec.last_status_date IS NULL
   THEN
      IF p_evh_rec.user_status_id = l_evh_rec.user_status_id THEN
      -- no status change, set it to be the original value
         x_complete_rec.last_status_date := l_evh_rec.last_status_date;
      ELSE
      -- status changed, set it to be SYSDATE
         x_complete_rec.last_status_date := SYSDATE;
      END IF;
   END IF;

   IF p_evh_rec.stream_type_code = FND_API.g_miss_char THEN
      x_complete_rec.stream_type_code := l_evh_rec.stream_type_code;
   END IF;

   -- sugupta 03/29/00 source_code can be updated by the user until status is not active.
   -- if it is passed from screen, it will be validated under check_evh_update

   IF p_evh_rec.source_code = FND_API.g_miss_char THEN
      x_complete_rec.source_code := l_evh_rec.source_code;
   END IF;

   IF p_evh_rec.event_standalone_flag = FND_API.g_miss_char THEN
      x_complete_rec.event_standalone_flag := l_evh_rec.event_standalone_flag;
   END IF;

   IF p_evh_rec.day_of_event = FND_API.g_miss_char THEN
      x_complete_rec.day_of_event := l_evh_rec.day_of_event;
   END IF;

  IF p_evh_rec.agenda_start_time = FND_API.g_miss_date THEN
      x_complete_rec.agenda_start_time := l_evh_rec.agenda_start_time;
   END IF;

   IF p_evh_rec.agenda_end_time = FND_API.g_miss_date THEN
      x_complete_rec.agenda_end_time := l_evh_rec.agenda_end_time;
   END IF;

   IF p_evh_rec.reg_required_flag = FND_API.g_miss_char THEN
      x_complete_rec.reg_required_flag := l_evh_rec.reg_required_flag;
   END IF;

   IF p_evh_rec.reg_charge_flag = FND_API.g_miss_char THEN
      x_complete_rec.reg_charge_flag := l_evh_rec.reg_charge_flag;
   END IF;

   IF p_evh_rec.reg_invited_only_flag = FND_API.g_miss_char THEN
      x_complete_rec.reg_invited_only_flag := l_evh_rec.reg_invited_only_flag;
   END IF;

   IF p_evh_rec.partner_flag = FND_API.g_miss_char THEN
      x_complete_rec.partner_flag := l_evh_rec.partner_flag;
   END IF;

   IF p_evh_rec.overflow_flag = FND_API.g_miss_char THEN
      x_complete_rec.overflow_flag := l_evh_rec.overflow_flag;
   END IF;

   IF p_evh_rec.parent_event_header_id = FND_API.g_miss_num THEN
      x_complete_rec.parent_event_header_id := l_evh_rec.parent_event_header_id;
   END IF;

   IF p_evh_rec.duration = FND_API.g_miss_num THEN
      x_complete_rec.duration := l_evh_rec.duration;
   END IF;

   IF p_evh_rec.duration_uom_code = FND_API.g_miss_char THEN
      x_complete_rec.duration_uom_code := l_evh_rec.duration_uom_code;
   END IF;

   IF p_evh_rec.active_from_date = FND_API.g_miss_date THEN
      x_complete_rec.active_from_date := l_evh_rec.active_from_date;
   END IF;

   IF p_evh_rec.active_to_date = FND_API.g_miss_date THEN
      x_complete_rec.active_to_date := l_evh_rec.active_to_date;
   END IF;

   IF p_evh_rec.reg_maximum_capacity = FND_API.g_miss_num THEN
      x_complete_rec.reg_maximum_capacity := l_evh_rec.reg_maximum_capacity;
   END IF;

   IF p_evh_rec.reg_minimum_capacity = FND_API.g_miss_num THEN
      x_complete_rec.reg_minimum_capacity := l_evh_rec.reg_minimum_capacity;
   END IF;

   IF p_evh_rec.main_language_code = FND_API.g_miss_char THEN
      x_complete_rec.main_language_code := l_evh_rec.main_language_code;
   END IF;

   IF p_evh_rec.cert_credit_type_code = FND_API.g_miss_char THEN
      x_complete_rec.cert_credit_type_code := l_evh_rec.cert_credit_type_code;
   END IF;

   IF p_evh_rec.certification_credits = FND_API.g_miss_num THEN
      x_complete_rec.certification_credits := l_evh_rec.certification_credits;
   END IF;

   IF p_evh_rec.inventory_item_id = FND_API.g_miss_num THEN
      x_complete_rec.inventory_item_id := l_evh_rec.inventory_item_id;
   END IF;

   IF p_evh_rec.organization_id = FND_API.g_miss_num THEN
      x_complete_rec.organization_id := l_evh_rec.organization_id;
   END IF;

   IF p_evh_rec.org_id = FND_API.g_miss_num THEN
      x_complete_rec.org_id := l_evh_rec.org_id;
   END IF;

   IF p_evh_rec.forecasted_revenue = FND_API.g_miss_num THEN
      x_complete_rec.forecasted_revenue := l_evh_rec.forecasted_revenue;
   END IF;

   IF p_evh_rec.actual_revenue = FND_API.g_miss_num THEN
      x_complete_rec.actual_revenue := l_evh_rec.actual_revenue;
   END IF;

   IF p_evh_rec.forecasted_cost = FND_API.g_miss_num THEN
      x_complete_rec.forecasted_cost := l_evh_rec.forecasted_cost;
   END IF;

   IF p_evh_rec.actual_cost = FND_API.g_miss_num THEN
      x_complete_rec.actual_cost := l_evh_rec.actual_cost;
   END IF;

   IF p_evh_rec.coordinator_id = FND_API.g_miss_num THEN
      x_complete_rec.coordinator_id := l_evh_rec.coordinator_id;
   END IF;

   IF p_evh_rec.fund_source_type_code = FND_API.g_miss_char THEN
      x_complete_rec.fund_source_type_code := l_evh_rec.fund_source_type_code;
   END IF;

   IF p_evh_rec.fund_source_id = FND_API.g_miss_num THEN
      x_complete_rec.fund_source_id := l_evh_rec.fund_source_id;
   END IF;

   IF p_evh_rec.fund_amount_tc = FND_API.g_miss_num THEN
      x_complete_rec.fund_amount_tc := l_evh_rec.fund_amount_tc;
   END IF;

   IF p_evh_rec.fund_amount_fc = FND_API.g_miss_num THEN
      x_complete_rec.fund_amount_fc := l_evh_rec.fund_amount_fc;
   END IF;

   IF p_evh_rec.currency_code_tc = FND_API.g_miss_char THEN
      x_complete_rec.currency_code_tc := l_evh_rec.currency_code_tc;
   END IF;

   IF p_evh_rec.currency_code_fc = FND_API.g_miss_char THEN
      x_complete_rec.currency_code_fc := l_evh_rec.currency_code_fc;
   END IF;

   IF p_evh_rec.owner_user_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_user_id := l_evh_rec.owner_user_id;
   END IF;

   IF p_evh_rec.url = FND_API.g_miss_char THEN
      x_complete_rec.url := l_evh_rec.url;
   END IF;

   IF p_evh_rec.phone = FND_API.g_miss_char THEN
      x_complete_rec.phone := l_evh_rec.phone;
   END IF;

   IF p_evh_rec.email = FND_API.g_miss_char THEN
      x_complete_rec.email := l_evh_rec.email;
   END IF;

   IF p_evh_rec.priority_type_code = FND_API.g_miss_char THEN
      x_complete_rec.priority_type_code := l_evh_rec.priority_type_code;
   END IF;

   IF p_evh_rec.cancellation_reason_code = FND_API.g_miss_char THEN
      x_complete_rec.cancellation_reason_code := l_evh_rec.cancellation_reason_code;
   END IF;

   IF p_evh_rec.inbound_script_name = FND_API.g_miss_char THEN
      x_complete_rec.inbound_script_name := l_evh_rec.inbound_script_name;
   END IF;

   IF p_evh_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_evh_rec.attribute_category;
   END IF;

   IF p_evh_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_evh_rec.attribute1;
   END IF;

   IF p_evh_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_evh_rec.attribute2;
   END IF;

   IF p_evh_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_evh_rec.attribute3;
   END IF;

   IF p_evh_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_evh_rec.attribute4;
   END IF;

   IF p_evh_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_evh_rec.attribute5;
   END IF;

   IF p_evh_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_evh_rec.attribute6;
   END IF;

   IF p_evh_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_evh_rec.attribute7;
   END IF;

   IF p_evh_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_evh_rec.attribute8;
   END IF;

   IF p_evh_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_evh_rec.attribute9;
   END IF;

   IF p_evh_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_evh_rec.attribute10;
   END IF;

   IF p_evh_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_evh_rec.attribute11;
   END IF;

   IF p_evh_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_evh_rec.attribute12;
   END IF;

   IF p_evh_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_evh_rec.attribute13;
   END IF;

   IF p_evh_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_evh_rec.attribute14;
   END IF;

   IF p_evh_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_evh_rec.attribute15;
   END IF;

   IF p_evh_rec.event_header_name = FND_API.g_miss_char THEN
      x_complete_rec.event_header_name := l_evh_rec.event_header_name;
   END IF;

   IF p_evh_rec.event_mktg_message = FND_API.g_miss_char THEN
      x_complete_rec.event_mktg_message := l_evh_rec.event_mktg_message;
   END IF;

   IF p_evh_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_evh_rec.description;
   END IF;

   IF p_evh_rec.country_code = FND_API.g_miss_char THEN
      x_complete_rec.country_code := l_evh_rec.country_code;
   END IF;

   IF p_evh_rec.business_unit_id = FND_API.g_miss_num THEN
      x_complete_rec.business_unit_id := l_evh_rec.business_unit_id;
   END IF;
   IF p_evh_rec.event_calendar = FND_API.g_miss_char THEN
      x_complete_rec.event_calendar := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
   END IF;

   IF p_evh_rec.start_period_name = FND_API.g_miss_char THEN
      x_complete_rec.start_period_name := l_evh_rec.start_period_name;
   END IF;

   IF p_evh_rec.end_period_name = FND_API.g_miss_char THEN
      x_complete_rec.end_period_name := l_evh_rec.end_period_name;
   END IF;

   IF p_evh_rec.global_flag = FND_API.g_miss_char THEN
      x_complete_rec.global_flag := l_evh_rec.global_flag;
   END IF;

   IF p_evh_rec.task_id = FND_API.g_miss_num THEN
      x_complete_rec.task_id := l_evh_rec.task_id;
   END IF;
      IF p_evh_rec.program_id = FND_API.g_miss_num THEN
      x_complete_rec.program_id := l_evh_rec.program_id;
   END IF;
      IF p_evh_rec.CREATE_ATTENDANT_LEAD_FLAG = FND_API.g_miss_char THEN
      x_complete_rec.CREATE_ATTENDANT_LEAD_FLAG := l_evh_rec.CREATE_ATTENDANT_LEAD_FLAG;
   END IF;
      IF p_evh_rec.CREATE_REGISTRANT_LEAD_FLAG = FND_API.g_miss_char THEN
      x_complete_rec.CREATE_REGISTRANT_LEAD_FLAG := l_evh_rec.CREATE_REGISTRANT_LEAD_FLAG;
   END IF;

        IF p_evh_rec.event_purpose_code = FND_API.g_miss_char  THEN
                x_complete_rec.event_purpose_code := l_evh_rec.event_purpose_code;  /* Hornet : added  aug13*/
        END IF;

   --EXCEPTION
   --WHEN OTHERS THEN
     -- ROLLBACK TO update_campaign;
      --x_return_status := FND_API.g_ret_sts_unexp_error;

      --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                --THEN
         --FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      --END IF;

      --FND_MSG_PUB.count_and_get(
       --     p_encoded => FND_API.g_false,
        --    p_count   => x_msg_count,
        --    p_data    => x_msg_data
      --);


END complete_evh_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    unit_test_update
--
-- HISTORY
--    01/19/2000  gdeodhar  Created.
---------------------------------------------------------------------
PROCEDURE unit_test_update
IS

        l_evh_rec                       AMS_EVENTHEADER_PVT.evh_rec_type;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(200);
    l_evh_id                    AMS_EVENT_HEADERS_ALL_B.event_header_id%type;

BEGIN

        l_evh_rec.event_header_id := 10009 ;
        l_evh_rec.object_version_number := 1 ;
        l_evh_rec.day_of_event := 'ONE' ;
        l_evh_rec.stream_type_code := 'A' ;
        --l_evh_rec.agenda_start_time := to_date(to_char('1970-01-01 10:00:00.0', 'HH24:MI'), 'HH24:MI') ;
        --l_evh_rec.agenda_end_time := to_date(to_char('1970-01-01 10:30:00.0', 'HH24.MI'), 'HH24:MI') ;
        l_evh_rec.agenda_start_time := to_date('15:00', 'HH24:MI') ;
        l_evh_rec.agenda_end_time := to_date('13:00', 'HH24.MI') ;
        l_evh_rec.event_header_name := 'Test 2' ;
        l_evh_rec.user_status_id := 16 ;
        l_evh_rec.system_status_code := 'PLANNING' ;
        l_evh_rec.application_id := 530 ;

    AMS_EVENTHEADER_PVT.update_event_header(
         p_api_version                  => 1.0                                   -- p_api_version
        ,p_init_msg_list                => FND_API.G_FALSE
        ,p_commit                               => FND_API.G_FALSE
        ,p_validation_level             => FND_API.G_VALID_LEVEL_FULL
        ,x_return_status                => l_return_status
        ,x_msg_count                    => l_msg_count
        ,x_msg_data                             => l_msg_data
                ,p_evh_rec                              => l_evh_rec
        );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                AMS_UTILITY_PVT.display_messages;
     ELSE
                commit work;
                AMS_UTILITY_PVT.display_messages;
         END IF;

END unit_test_update;

-------------------------------------------------------

-------------------------------------------------------------
--       Check_Parent_Active
-------------------------------------------------------------
PROCEDURE Check_Parent_Active (
        p_evh_rec          IN  evh_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2
)IS
l_evh_rec   evh_rec_type;
l_system_status_code p_evh_rec.system_status_code%TYPE ;

   CURSOR c_program IS
         SELECT status_code FROM ams_campaigns_v
                 WHERE campaign_id = p_evh_rec.program_id;

 BEGIN
     x_return_status := FND_API.g_ret_sts_success;

     IF (p_evh_rec.event_level = 'MAIN' AND p_evh_rec.active_flag = 'Y' AND p_evh_rec.system_status_code = 'ACTIVE' ) THEN

           OPEN c_program;
           FETCH c_program INTO l_system_status_code;
           CLOSE c_program;

        IF  l_system_status_code <> 'ACTIVE'  THEN
            IF (AMS_DEBUG_HIGH_ON) THEN

                Ams_Utility_Pvt.debug_message('The Parent is not Active');
            END IF;
            Fnd_Message.set_name('AMS', 'AMS_PROGRAM_NOT_ACTIVE');
            Fnd_Msg_Pub.ADD;
            x_return_status := Fnd_Api.g_ret_sts_error;
            RETURN;
       END IF;

    END IF;

END Check_Parent_Active;


-------------------------------------------------------------
--       Check_Dates_Range
-- History
-- 07-feb-2003  dbiswas added code c_eveo validation for event-event_sched
--                      start and end dates
-------------------------------------------------------------
PROCEDURE Check_Dates_Range (
        p_evh_rec          IN  evh_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2
)IS
l_evh_rec   evh_rec_type;
l_start_date DATE;
l_end_date DATE;

   CURSOR c_program IS
         SELECT actual_exec_start_date , actual_exec_end_date FROM ams_campaigns_vl
                 WHERE campaign_id = p_evh_rec.program_id;

     CURSOR c_eveo IS
    SELECT event_start_date AS start_date,
           event_end_date AS end_date
      FROM ams_event_offers_vl
   WHERE event_header_id = p_evh_rec.event_header_id and system_status_code<> 'CANCELLED';--implemented ER2381975 by anchaudh.


 BEGIN

     OPEN c_program;
     FETCH c_program INTO l_start_date,l_end_date;
     CLOSE c_program;

     x_return_status := FND_API.g_ret_sts_success;

     IF (p_evh_rec.active_from_date IS NOT NULL AND l_start_date IS NOT NULL ) THEN
         IF (p_evh_rec.active_from_date < l_start_date) THEN
                     IF (AMS_DEBUG_HIGH_ON) THEN

                         Ams_Utility_Pvt.debug_message('The start date of Event can not be lesser than that of Program');
                     END IF;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
                   Fnd_Message.set_name('AMS', 'AMS_EVT_STDT_LS_PRG_STDT');
                   Fnd_Msg_Pub.ADD;
                   x_return_status := Fnd_Api.g_ret_sts_error;
                   RETURN;
                END IF;
         END IF;
     END IF;

     IF (p_evh_rec.active_to_date IS NOT NULL AND l_end_date IS NOT NULL ) THEN
         IF (p_evh_rec.active_to_date > l_end_date) THEN
                     IF (AMS_DEBUG_HIGH_ON) THEN

                         Ams_Utility_Pvt.debug_message('The end date of Event can not be greater than that of Program');
                     END IF;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
                   Fnd_Message.set_name('AMS', 'AMS_EVT_EDDT_GT_PRG_EDDT');
                   Fnd_Msg_Pub.ADD;
                   x_return_status := Fnd_Api.g_ret_sts_error;
                   RETURN;
                END IF;
         END IF;
     ELSE
        IF ( p_evh_rec.active_to_date IS NULL AND l_end_date IS NOT NULL ) THEN
            IF (AMS_DEBUG_HIGH_ON) THEN

                Ams_Utility_Pvt.debug_message('The end date of Event can not be greater than that of Program');
            END IF;
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
               Fnd_Message.set_name('AMS', 'AMS_EVT_EDDT_GT_PRG_EDDT');
               Fnd_Msg_Pub.ADD;
               x_return_status := Fnd_Api.g_ret_sts_error;
               RETURN;
            END IF;
        END IF;
    END IF;

   FOR l_eveo_rec in c_eveo LOOP
    IF(p_evh_rec.active_from_date <>FND_API.g_miss_date OR l_eveo_rec.start_date<> FND_API.g_miss_date )THEN
     IF (p_evh_rec.active_from_date IS NOT NULL AND l_eveo_rec.start_date IS NOT NULL ) THEN
         IF (l_eveo_rec.start_date < p_evh_rec.active_from_date) THEN
                     IF (AMS_DEBUG_HIGH_ON) THEN
                         Ams_Utility_Pvt.debug_message('The start date of an Offer can not be lesser than that of Event');
                     END IF;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
                   Fnd_Message.set_name('AMS', 'AMS_EVEO_STDT_LS_EVT_STDT');
                   Fnd_Msg_Pub.ADD;
                   x_return_status := Fnd_Api.g_ret_sts_error;
                   RETURN;
                END IF;
         END IF;
      ELSIF(p_evh_rec.active_from_date IS NULL AND l_eveo_rec.start_date IS NOT NULL) THEN
               IF (AMS_DEBUG_HIGH_ON) THEN
                         Ams_Utility_Pvt.debug_message('The start date of an Offer can not be lesser than that of Event');
               END IF;
               IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
                   Fnd_Message.set_name('AMS', 'AMS_EVEO_STDT_LS_EVT_STDT');
                   Fnd_Msg_Pub.ADD;
                   x_return_status := Fnd_Api.g_ret_sts_error;
                   RETURN;
                END IF;
             END IF;
   END IF;

   IF(p_evh_rec.active_from_date <>FND_API.g_miss_date OR l_eveo_rec.start_date<> FND_API.g_miss_date )THEN
     IF (p_evh_rec.active_to_date IS NOT NULL AND l_eveo_rec.end_date IS NOT NULL ) THEN
         IF (p_evh_rec.active_to_date < l_eveo_rec.end_date) THEN
                     IF (AMS_DEBUG_HIGH_ON) THEN

                         Ams_Utility_Pvt.debug_message('The end date of Event can not be lesser than that of Offer');
                     END IF;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
                   Fnd_Message.set_name('AMS', 'AMS_EVEO_EDDT_GT_EVT_EDDT');
                   Fnd_Msg_Pub.ADD;
                   x_return_status := Fnd_Api.g_ret_sts_error;
                   RETURN;
                END IF;
         END IF;
     ELSIF ( p_evh_rec.active_to_date IS NOT NULL AND l_eveo_rec.end_date IS NULL ) THEN
            IF (AMS_DEBUG_HIGH_ON) THEN

                Ams_Utility_Pvt.debug_message('The end date of Offer can not be greater than that of Event');
            END IF;
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
               Fnd_Message.set_name('AMS', 'AMS_EVEO_EDDT_GT_EVT_EDDT');
               Fnd_Msg_Pub.ADD;
               x_return_status := Fnd_Api.g_ret_sts_error;
               RETURN;
            END IF;
        END IF;
    END IF;
  END LOOP;
END Check_Dates_Range;
--------------------------------------------------------------------
-------------------------------------------------------------
--       Update_Metrics
-------------------------------------------------------------
PROCEDURE Update_Metrics (
        p_evh_rec          IN  evh_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2,
   x_msg_count OUT NOCOPY VARCHAR2,
   x_msg_data OUT NOCOPY VARCHAR2
 ) IS
l_program_id NUMBER;
l_api_version CONSTANT NUMBER  := 1.0;


CURSOR c_program IS

        SELECT program_id from ams_event_headers_v
        WHERE event_header_id = p_evh_rec.event_header_id;
 BEGIN

     OPEN c_program;
     FETCH c_program INTO l_program_id;
     CLOSE c_program;

     x_return_status := FND_API.g_ret_sts_success;

     /* The AMS_ACTMETRIC_PVT.INVALIDATE_ROLLUP should be called
        1) When Program is removed or updated (changed)
        2) No need of calling when program is attached first time
      */

      IF( l_program_id IS NOT NULL )THEN
        IF( l_program_id <> nvl(p_evh_rec.program_id,0))THEN
            AMS_ACTMETRIC_PVT.INVALIDATE_ROLLUP(
               p_api_version => l_api_version,
               p_init_msg_list   => Fnd_Api.g_false,
               p_commit  => Fnd_Api.G_FALSE,

               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,

               p_used_by_type => 'EVEH',
               p_used_by_id => p_evh_rec.event_header_id
            );

           IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
               RAISE Fnd_Api.g_exc_unexpected_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
               RAISE Fnd_Api.g_exc_error;
           END IF;
        END IF;
    END IF;


 END Update_Metrics;

 ------------------------------------------------------------------------------------------
END AMS_EventHeader_PVT;

/
