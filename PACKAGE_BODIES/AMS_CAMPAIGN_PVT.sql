--------------------------------------------------------
--  DDL for Package Body AMS_CAMPAIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMPAIGN_PVT" AS
/* $Header: amsvcpnb.pls 120.4 2006/07/21 05:48:33 prageorg ship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='AMS_Campaign_PVT';


---------------------------------------------------------------------
-- PROCEDURE
--    create_campaign
--
-- HISTORY
--    10/01/99  holiu     Created.
--    08/31/00  ptendulk  Added nvl in the insert statement for
--                        global flag.
--    09/27/00  ptendulk  Added currency conversion api to conver the
--                        transaction currency into functional currency
--    01/23/01  julou     Commented out budget_amount_tc, budget_amount_fc,
--                        media_type_code, media_id, channel_id from insert
-- 06-Feb-2001  ptendulk  Added program descriptive flexfield attributes.
-- 31-May-2001  ptendulk  Changed the call to copy seeded metric. pass RCAM for programs
---------------------------------------------------------------------
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  camp_rec_type,
   x_camp_id           OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_campaign';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status  VARCHAR2(1);
   l_camp_rec       camp_rec_type := p_camp_rec;
   l_camp_count     NUMBER;
   l_bu_id          NUMBER;
   l_org_id         NUMBER;

   CURSOR c_camp_seq IS
   SELECT ams_campaigns_all_b_s.NEXTVAL
     FROM DUAL;

   CURSOR c_camp_count(camp_id IN NUMBER) IS
   SELECT COUNT(*)
     FROM ams_campaigns_vl
    WHERE campaign_id = camp_id;

    /**
    CURSOR c_parent_business_unit (p_parent_campaign_id IN NUMBER, p_org_id IN NUMBER) IS
    SELECT business_unit_id
    from ams_campaigns_all_b
    where campaign_id = p_parent_campaign_id
    and exists (
        SELECT 1 FROM hr_all_organization_units_vl
        WHERE business_group_id IN (
        SELECT business_group_id FROM hr_all_organization_units_vl
        WHERE organization_id = p_org_id
        AND NVL(date_from, SYSDATE) <= SYSDATE
        AND NVL(date_to, SYSDATE) >= SYSDATE)
        AND type = 'BU'
        AND NVL(date_from, SYSDATE) <= SYSDATE
        AND NVL(date_to, SYSDATE) >= SYSDATE
        AND organization_id = business_unit_id
        );
     **/

    CURSOR c_parent_business_unit (p_parent_campaign_id IN NUMBER) IS
    SELECT business_unit_id
    from ams_campaigns_all_b
    where campaign_id = p_parent_campaign_id
    and exists (
        SELECT 1
        FROM hr_all_organization_units_vl
        WHERE business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
        AND NVL(date_from, SYSDATE) <= SYSDATE
        AND NVL(date_to, SYSDATE) >= SYSDATE
        AND type = 'BU'
        AND organization_id = business_unit_id);

     CURSOR c_parent_confi_flag (p_parent_campaign_id IN NUMBER) IS
     select private_flag
     from ams_campaigns_all_b
     where campaign_id = p_parent_campaign_id;

   l_access_rec   AMS_Access_Pvt.access_rec_type ;
   l_dummy_id     NUMBER ;
   l_rollup_type  VARCHAR2(30);

   l_related_source_code  VARCHAR2(30) ;
   l_related_source_id    NUMBER ;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_campaign;

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

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;

   -- Following code is commented by ptendulk on 06-Feb-2001
   -- as we are not using inherit attribute flag
   -- This might need to be changed if we define any criteria for
   -- copying campaigns attribute when campaign being copied.
   --
   -- handle inherit_attributes_flag
   --AMS_CampaignRules_PVT.handle_camp_inherit_flag(
   --   p_camp_rec.parent_campaign_id,
   --   p_camp_rec.rollup_type,
   --   l_camp_rec.inherit_attributes_flag,
   --   l_return_status
   --);
   --IF l_return_status = FND_API.g_ret_sts_error THEN
   --   RAISE FND_API.g_exc_error;
   --ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
   --   RAISE FND_API.g_exc_unexpected_error;
   --END IF;

   -- handle status
   AMS_CampaignRules_PVT.handle_camp_status(
      p_camp_rec.user_status_id,
      l_camp_rec.status_code,
      l_return_status
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- default campaign calendar
   IF l_camp_rec.campaign_calendar IS NULL
      AND (l_camp_rec.start_period_name IS NOT NULL
      OR l_camp_rec.end_period_name IS NOT NULL)
   THEN
      l_camp_rec.campaign_calendar := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
   END IF;

   -- default source_code
   IF l_camp_rec.source_code IS NULL AND
      l_camp_rec.rollup_type <> 'RCAM'
   THEN
      -- choang - 16-May-2000
      -- Replaced get_source_code with get_new_source_code
      -- NOTE: must implement global flag
      l_camp_rec.source_code := AMS_SourceCode_PVT.get_new_source_code (
         p_object_type  => 'CAMP',
         p_custsetup_id => l_camp_rec.custom_setup_id,
         p_global_flag  => l_camp_rec.global_flag
      );
      --l_camp_rec.source_code := AMS_SourceCode_PVT.get_source_code(
      --   'CAMP',
      --   l_camp_rec.campaign_type
      --);
   END IF;

   validate_campaign(
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_camp_rec           => l_camp_rec
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;



   -- ==========================================================
   -- Following code is added by ptendulk on 09/27/2000
   -- the code will convert the transaction currency in to
   -- functional currency.
   -- ==========================================================
   IF l_camp_rec.budget_amount_tc IS NOT NULL THEN
       AMS_CampaignRules_PVT.Convert_Camp_Currency(
           p_tc_curr     => l_camp_rec.transaction_currency_code,
           p_tc_amt      => l_camp_rec.budget_amount_tc,
           x_fc_curr     => l_camp_rec.functional_currency_code,
           x_fc_amt      => l_camp_rec.budget_amount_fc
           ) ;
   END IF ;


   -- try to generate a unique id from the sequence
   IF l_camp_rec.campaign_id IS NULL THEN
      LOOP
         OPEN c_camp_seq;
         FETCH c_camp_seq INTO l_camp_rec.campaign_id;
         CLOSE c_camp_seq;

         OPEN c_camp_count(l_camp_rec.campaign_id);
         FETCH c_camp_count INTO l_camp_count;
         CLOSE c_camp_count;

         EXIT WHEN l_camp_count = 0;
      END LOOP;
   END IF ;

   -- Added by rmajumda (09/15/05). MOAC changes
   l_org_id := fnd_profile.value('DEFAULT_ORG_ID');

   -- Logic for Business Unit (8-Aug-2005 mayjain)
    if (l_camp_rec.parent_campaign_id is not null)
    then
        --OPEN c_parent_business_unit (l_camp_rec.parent_campaign_id, fnd_profile.value('ORG_ID'));
        -- MOAC changes
        OPEN c_parent_business_unit (l_camp_rec.parent_campaign_id);
        FETCH c_parent_business_unit into l_camp_rec.business_unit_id;
        CLOSE c_parent_business_unit;

        AMS_Utility_PVT.debug_message(l_full_name ||': Business Unit = ' || to_char(l_camp_rec.business_unit_id));
        AMS_Utility_PVT.debug_message(l_full_name ||': Parent Campaign Id = ' || to_char(l_camp_rec.parent_campaign_id));
        AMS_Utility_PVT.debug_message(l_full_name ||': Org Id  = ' || to_char(fnd_profile.value('ORG_ID')));

        OPEN c_parent_confi_flag (l_camp_rec.parent_campaign_id);
        FETCH c_parent_confi_flag into l_camp_rec.private_flag;
        CLOSE c_parent_confi_flag;
    end if;
   -- Logic for Business Unit (8-Aug-2005 mayjain)



   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;

   -----------------------------------------------------------------
   -- budget_amount_tc, budget_amount_fc, media_type_code, media_id,
   -- channel_id are commented out by julou on 01/23/00
   -----------------------------------------------------------------
   INSERT INTO ams_campaigns_all_b(
      campaign_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      object_version_number,
      owner_user_id,
      user_status_id,
      status_code,
      status_date,
      active_flag,
      private_flag,
      partner_flag,
      template_flag,
      cascade_source_code_flag,
      inherit_attributes_flag,
      source_code,
      rollup_type,
      campaign_type,
      media_type_code,
      priority,
      fund_source_type,
      fund_source_id,
      parent_campaign_id,
      application_id,
      qp_list_header_id,
      org_id,
      media_id,
      channel_id,
      event_type,
      arc_channel_from,
      dscript_name,
      transaction_currency_code,
      functional_currency_code,
      budget_amount_tc,
      budget_amount_fc,
      forecasted_plan_start_date,
      forecasted_plan_end_date,
      forecasted_exec_start_date,
      forecasted_exec_end_date,
      actual_plan_start_date,
      actual_plan_end_date,
      actual_exec_start_date,
      actual_exec_end_date,
      inbound_url,
      inbound_email_id,
      inbound_phone_no,
      duration,
      duration_uom_code,
      ff_priority,
      ff_override_cover_letter,
      ff_shipping_method,
      ff_carrier,
      content_source,
      cc_call_strategy,
      cc_manager_user_id,
      forecasted_revenue,
      actual_revenue,
      forecasted_cost,
      actual_cost,
      forecasted_response,
      actual_response,
      target_response,
      country_code,
      language_code,
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
      version_no,
      campaign_calendar,
      start_period_name,
      end_period_name,
      city_id,
      global_flag,
      custom_setup_id,
      show_campaign_flag,
      business_unit_id,
      accounts_closed_flag,
      task_id,
      related_event_from,
      related_event_id,
      program_attribute_category,
      program_attribute1,
      program_attribute2,
      program_attribute3,
      program_attribute4,
      program_attribute5,
      program_attribute6,
      program_attribute7,
      program_attribute8,
      program_attribute9,
      program_attribute10,
      program_attribute11,
      program_attribute12,
      program_attribute13,
      program_attribute14,
      program_attribute15
      )
   VALUES(
      l_camp_rec.campaign_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      1,  -- object_version_number
      l_camp_rec.owner_user_id,
      l_camp_rec.user_status_id,
      l_camp_rec.status_code,
      NVL(l_camp_rec.status_date, SYSDATE),
      NVL(l_camp_rec.active_flag, 'Y'),
      NVL(l_camp_rec.private_flag, 'N'),
      NVL(l_camp_rec.partner_flag, 'N'),
      NVL(l_camp_rec.template_flag, 'N'),
      NVL(l_camp_rec.cascade_source_code_flag, 'N'),
      NVL(l_camp_rec.inherit_attributes_flag,'N'),
      l_camp_rec.source_code,
      l_camp_rec.rollup_type,
      l_camp_rec.campaign_type,
      l_camp_rec.media_type_code,
      NVL(l_camp_rec.priority, 'STANDARD'),
      l_camp_rec.fund_source_type,
      l_camp_rec.fund_source_id,
      l_camp_rec.parent_campaign_id,
      l_camp_rec.application_id,
      l_camp_rec.qp_list_header_id,
      l_org_id, -- org_id value from MO: Default Org Id,
      -- commenting out. moac changes.
      --TO_NUMBER(SUBSTRB(userenv('CLIENT_INFO'),1,10)), -- org_id
      l_camp_rec.media_id,
      l_camp_rec.channel_id,
      l_camp_rec.event_type,
      l_camp_rec.arc_channel_from,
      l_camp_rec.dscript_name,
      l_camp_rec.transaction_currency_code,
      l_camp_rec.functional_currency_code,
      l_camp_rec.budget_amount_tc,
      l_camp_rec.budget_amount_fc,
      l_camp_rec.forecasted_plan_start_date,
      l_camp_rec.forecasted_plan_end_date,
      l_camp_rec.forecasted_exec_start_date,
      l_camp_rec.forecasted_exec_end_date,
      l_camp_rec.actual_plan_start_date,
      l_camp_rec.actual_plan_end_date,
      l_camp_rec.actual_exec_start_date,
      l_camp_rec.actual_exec_end_date,
      l_camp_rec.inbound_url,
      l_camp_rec.inbound_email_id,
      l_camp_rec.inbound_phone_no,
      l_camp_rec.duration,
      l_camp_rec.duration_uom_code,
      l_camp_rec.ff_priority,
      l_camp_rec.ff_override_cover_letter,
      l_camp_rec.ff_shipping_method,
      l_camp_rec.ff_carrier,
      l_camp_rec.content_source,
      l_camp_rec.cc_call_strategy,
      l_camp_rec.cc_manager_user_id,
      l_camp_rec.forecasted_revenue,
      l_camp_rec.actual_revenue,
      l_camp_rec.forecasted_cost,
      l_camp_rec.actual_cost,
      l_camp_rec.forecasted_response,
      l_camp_rec.actual_response,
      l_camp_rec.target_response,
      l_camp_rec.country_code,
      l_camp_rec.language_code,
      l_camp_rec.attribute_category,
      l_camp_rec.attribute1,
      l_camp_rec.attribute2,
      l_camp_rec.attribute3,
      l_camp_rec.attribute4,
      l_camp_rec.attribute5,
      l_camp_rec.attribute6,
      l_camp_rec.attribute7,
      l_camp_rec.attribute8,
      l_camp_rec.attribute9,
      l_camp_rec.attribute10,
      l_camp_rec.attribute11,
      l_camp_rec.attribute12,
      l_camp_rec.attribute13,
      l_camp_rec.attribute14,
      l_camp_rec.attribute15,
      null, -- version_no
      l_camp_rec.campaign_calendar,
      l_camp_rec.start_period_name,
      l_camp_rec.end_period_name,
      NVL(l_camp_rec.city_id, TO_NUMBER(FND_PROFILE.value('AMS_SRCGEN_USER_CITY'))),
      NVL(l_camp_rec.global_flag, 'N'),
      l_camp_rec.custom_setup_id,
      NVL(l_camp_rec.show_campaign_flag, 'Y'),
      l_camp_rec.business_unit_id,
--07-apr-2003 cgoyal
      'N',  --NVL(l_camp_rec.accounts_closed_flag,'Y'),
--end 07-apr-2003 cgoyal
      l_camp_rec.task_id,
      l_camp_rec.related_event_from,
      l_camp_rec.related_event_id,
      l_camp_rec.program_attribute_category,
      l_camp_rec.program_attribute1,
      l_camp_rec.program_attribute2,
      l_camp_rec.program_attribute3,
      l_camp_rec.program_attribute4,
      l_camp_rec.program_attribute5,
      l_camp_rec.program_attribute6,
      l_camp_rec.program_attribute7,
      l_camp_rec.program_attribute8,
      l_camp_rec.program_attribute9,
      l_camp_rec.program_attribute10,
      l_camp_rec.program_attribute11,
      l_camp_rec.program_attribute12,
      l_camp_rec.program_attribute13,
      l_camp_rec.program_attribute14,
      l_camp_rec.program_attribute15
);

   INSERT INTO ams_campaigns_all_tl(
      campaign_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      campaign_name,
      campaign_theme,
      description
   )
   SELECT
      l_camp_rec.campaign_id,
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      l_camp_rec.campaign_name,
      l_camp_rec.campaign_theme,
      l_camp_rec.description
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM ams_campaigns_all_tl t
         WHERE t.campaign_id = l_camp_rec.campaign_id
         AND t.language = l.language_code );


   IF l_camp_rec.rollup_type <> 'RCAM' THEN
      -- need to push the source code to ams_source_codes
      --=====================================================================
      -- Following Code is added by ptendulk on 08-Oct-2001 to create related
      -- source information
      -- ====================================================================
      l_related_source_code := null ;
      IF p_camp_rec.related_event_from IS NOT NULL AND
         p_camp_rec.related_event_from <> FND_API.G_MISS_CHAR THEN

         l_related_source_code :=  AMS_CampaignRules_PVT.get_event_source_code(p_camp_rec.related_event_from,p_camp_rec.related_event_id);
      END IF ;


      AMS_CampaignRules_PVT.push_source_code(
         l_camp_rec.source_code,
         'CAMP',
         l_camp_rec.campaign_id,
         l_related_source_code,
         p_camp_rec.related_event_from,
         p_camp_rec.related_event_id
      );
   END IF;

   -- Following code is commented by ptendulk as we are no longer writing in to attributes.
   -- create object attributes
   --IF p_camp_rec.custom_setup_id IS NOT NULL THEN
   --   AMS_ObjectAttribute_PVT.create_object_attributes(
   --      p_api_version       => 1.0,
   --      p_init_msg_list     => FND_API.g_false,
   --      p_commit            => FND_API.g_false,
   --      p_validation_level  => FND_API.g_valid_level_full,
   --      x_return_status     => l_return_status,
   --      x_msg_count         => x_msg_count,
   --      x_msg_data          => x_msg_data,
   --      p_object_type       => 'CAMP',
   --      p_object_id         => l_camp_rec.campaign_id,
   --      p_setup_id          => p_camp_rec.custom_setup_id
   --   );
   --   IF l_return_status = FND_API.g_ret_sts_error THEN
   --      RAISE FND_API.g_exc_error;
   --   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
   --      RAISE FND_API.g_exc_unexpected_error;
   --   END IF;
   --END IF;

   -- create object association when channel is event
   --IF l_camp_rec.media_type_code = 'EVENTS'
   --   AND l_camp_rec.channel_id IS NOT NULL
   --THEN
   --   AMS_CampaignRules_PVT.create_camp_association(
   --      l_camp_rec.campaign_id,
   --      l_camp_rec.channel_id,
   --      l_camp_rec.arc_channel_from,
   --      l_return_status
   --   );
   --   IF l_return_status = FND_API.g_ret_sts_error THEN
   --      RAISE FND_API.g_exc_error;
   --   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
   --      RAISE FND_API.g_exc_unexpected_error;
   --   END IF;
   --END IF;

   -- Create Access for the owner
   l_access_rec.act_access_to_object_id := l_camp_rec.campaign_id ;
   IF l_camp_rec.rollup_type = 'RCAM' THEN
      l_rollup_type := 'RCAM' ;
   ELSE
      l_rollup_type := 'CAMP' ;
   END IF ;

   l_access_rec.arc_act_access_to_object := l_rollup_type ;
   l_access_rec.user_or_role_id := l_camp_rec.owner_user_id ;
   l_access_rec.arc_user_or_role_type := 'USER' ;
   l_access_rec.owner_flag := 'Y' ;
   l_access_rec.delete_flag := 'N' ;
   l_access_rec.admin_flag := 'Y' ;


   AMS_Access_Pvt.Create_Access(
           p_api_version       => l_api_version,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,

           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,

           p_access_rec        => l_access_rec,
           x_access_id         => l_dummy_id
        );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- p_arc_act_metric_used_by will have to be changed as l_rollup_type instead of 'CAMP'
   -- Waiting for gliu to resolve the issue.
   -- attach seeded metrics  as of Jun01-2001
   AMS_RefreshMetric_PVT.copy_seeded_metric(
      p_api_version => 1.0,
      x_return_status => l_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_arc_act_metric_used_by =>l_rollup_type,
      p_act_metric_used_by_id => l_camp_rec.campaign_id,
      p_act_metric_used_by_type => NULL
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   ------------------------- finish -------------------------------
   x_camp_id := l_camp_rec.campaign_id;

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
      ROLLBACK TO create_campaign;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_campaign;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_campaign;
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

END Create_Campaign;


---------------------------------------------------------------
-- PROCEDURE
--    delete_campaign
--
-- HISTORY
--    01-Oct-1999    holiu     Created.
--    11-Feb-2001    ptendulk  Delete the record if the status
--                             is new else update
---------------------------------------------------------------
PROCEDURE Delete_Campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_campaign';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   CURSOR c_camp IS
   SELECT status_code
   FROM   ams_campaigns_all_b
   WHERE  campaign_id = p_camp_id
   AND    object_version_number = p_object_version ;
   l_status VARCHAR2(30);

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_campaign;

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

   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   -- Start of code modified by ptendulk on 11-Feb-2001
   -- Delete the campaign if in new status.
   OPEN  c_camp ;
   FETCH c_camp INTO l_status ;
   IF c_camp%NOTFOUND THEN
      CLOSE c_camp ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF ;
   CLOSE c_camp ;

   IF l_status = 'NEW' THEN
      DELETE FROM ams_campaigns_all_b
      WHERE campaign_id = p_camp_id
      AND   object_version_number = p_object_version ;
   ELSE
      UPDATE ams_campaigns_all_b
      SET    active_flag = 'N'
      WHERE  campaign_id = p_camp_id
      AND    object_version_number = p_object_version;
   END IF  ;
   -- End of code modified by ptendulk on 11-Feb-2001

   --   UPDATE ams_campaigns_all_b
   --   SET    active_flag = 'N'
   --   WHERE  campaign_id = p_camp_id
   --   AND    object_version_number = p_object_version;

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
      ROLLBACK TO delete_campaign;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_campaign;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_campaign;
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

END Delete_Campaign;


-------------------------------------------------------------------
-- PROCEDURE
--    lock_campaign
--
-- HISTORY
--    10/01/99  holiu  Created.
--------------------------------------------------------------------
PROCEDURE Lock_Campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_id           IN  NUMBER,
   p_object_version    IN  NUMBER
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'lock_campaign';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_camp_id      NUMBER;

   CURSOR c_camp_b IS
   SELECT campaign_id
     FROM ams_campaigns_all_b
    WHERE campaign_id = p_camp_id
      AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

   CURSOR c_camp_tl IS
   SELECT campaign_id
     FROM ams_campaigns_all_tl
    WHERE campaign_id = p_camp_id
      AND USERENV('LANG') IN (language, source_lang)
   FOR UPDATE NOWAIT;

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

   OPEN c_camp_b;
   FETCH c_camp_b INTO l_camp_id;
   IF (c_camp_b%NOTFOUND) THEN
      CLOSE c_camp_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_camp_b;

   OPEN c_camp_tl;
   CLOSE c_camp_tl;

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

END Lock_Campaign;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Campaign
--
-- HISTORY
--    10/01/99  holiu     Created.
--    09/27/00  ptendulk  Added currency conversion api to conver the
--                        transaction currency into functional currency
--    01/23/01  julou     Commented out budget_amount_tc, budget_amount_fc,
--                        media_type_code, media_id, channel_id from update
-- 20-May-2001  ptendulk  Commented the if statement before update_camp_source_code
--                        Refer bug#1786964
-- 31-May-2001  ptendulk  Added call to invalidate parent if the parent is changed.
----------------------------------------------------------------------
PROCEDURE Update_Campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  camp_rec_type
)
IS

   l_source_code_for_event  VARCHAR2(30);
   -- end declaration change - 04/13/01 - for related_event

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_campaign';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_camp_rec       camp_rec_type;
   l_return_status  VARCHAR2(1);
   l_rollup_type  VARCHAR2(30);
   l_source_code  VARCHAR2(100);
BEGIN

   -------------------- initialize -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;
   SAVEPOINT update_campaign;

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

   -- replace g_miss_char/num/date with current column values
   complete_camp_rec(p_camp_rec, l_camp_rec);

   -- default campaign_calendar
   IF l_camp_rec.start_period_name IS NULL
      AND l_camp_rec.end_period_name IS NULL
   THEN
      l_camp_rec.campaign_calendar := NULL;
   ELSE
      l_camp_rec.campaign_calendar := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
   END IF;

   -- item level
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': check items');
   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_camp_items(
         p_camp_rec        => p_camp_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- record level
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': check record');
   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_camp_record(
         p_camp_rec       => p_camp_rec,
         p_complete_rec   => l_camp_rec,
         x_return_status  => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- inter-entity level
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': check inter-entity');
   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_inter_entity THEN
      check_camp_inter_entity(
         p_camp_rec        => p_camp_rec,
         p_complete_rec    => l_camp_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- check update
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': check update');
   END IF;
   AMS_CampaignRules_PVT.check_camp_update(
         p_camp_rec       => p_camp_rec,
         p_complete_rec   => l_camp_rec,
         x_return_status  => l_return_status
   );
   IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   ELSIF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   END IF;

   -- handle inherit_attributes_flag
   -- Following code is commented by ptendulk on 07-Feb-2001
   -- We are not using it any more.
   --IF (AMS_DEBUG_HIGH_ON) THENAMS_Utility_PVT.debug_message(l_full_name ||': handle inherit flag');END IF;
   --IF p_camp_rec.rollup_type <> FND_API.g_miss_char
   --   OR p_camp_rec.parent_campaign_id <> FND_API.g_miss_num
   --THEN
   --   AMS_CampaignRules_PVT.handle_camp_inherit_flag(
   --      l_camp_rec.parent_campaign_id,
   --      l_camp_rec.rollup_type,
   --      l_camp_rec.inherit_attributes_flag,
   --      l_return_status
   --   );
   --  IF l_return_status = FND_API.g_ret_sts_error THEN
   --      RAISE FND_API.g_exc_error;
   --   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
   --      RAISE FND_API.g_exc_unexpected_error;
   --   END IF;
   --END IF;

   -- handle source code update
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': update source code');
   END IF;
   IF p_camp_rec.source_code <> FND_API.g_miss_char
      OR p_camp_rec.global_flag <> FND_API.g_miss_char
      OR p_camp_rec.cascade_source_code_flag <> FND_API.g_miss_char
      OR (p_camp_rec.related_event_id IS NULL OR p_camp_rec.related_event_id <> FND_API.g_miss_num)
   THEN
      --Modified by rrajesh on 04/16/2001 - this method had been modified to
      --include related event also.
      /*AMS_CampaignRules_PVT.update_camp_source_code(
         l_camp_rec.campaign_id,
         l_camp_rec.source_code,
         l_camp_rec.global_flag,
         l_camp_rec.source_code,
         l_return_status
      );*/

      -- Following line is commented by ptendulk on 20-May-2001 Refer bug#1786964
      -- IF l_source_code_for_event <> FND_API.g_miss_char THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.Debug_message('Update the source_code ');
      END IF;

      AMS_CampaignRules_PVT.update_camp_source_code(
         l_camp_rec.campaign_id,
         l_camp_rec.source_code,
         l_camp_rec.global_flag,
         --l_camp_rec.source_code,
         l_source_code,
         l_camp_rec.related_event_from,
         l_camp_rec.related_event_id,
         l_return_status
      );
      -- END IF;
      --end change 04/16/2001 - rrajesh

      -- following code is added by ptendulk on 06-Dec-2002 to fix no copy issue.
      -- also changed : pass the variable l_source_code in above api instead of l_camp_rec.source_code
      l_camp_rec.source_code := l_source_code ;

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

  -- aranka added 13/12/01 bug# 2148325 start
     IF l_camp_rec.rollup_type = 'RCAM' THEN
      l_rollup_type := 'RCAM' ;
   ELSE
      l_rollup_type := 'CAMP' ;
   END IF ;


   -- Change the owner in Access table if the owner is changed.

   IF  p_camp_rec.owner_user_id <> FND_API.g_miss_num
   THEN
      AMS_CampaignRules_PVT.Update_Owner(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_object_type       => l_rollup_type ,
           p_campaign_id       => l_camp_rec.campaign_id,
           p_owner_id          => p_camp_rec.owner_user_id
           );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF ;

  -- aranka added 13/12/01 bug# 2148325 end

   -- following lines of code are added by ptendulk on 31-May-2001
   -- Change the rollup if the parent is changed
   IF  p_camp_rec.parent_campaign_id IS NULL OR
       p_camp_rec.parent_campaign_id  <> FND_API.g_miss_num
   THEN
      AMS_CampaignRules_PVT.Update_Rollup(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_campaign_id       => l_camp_rec.campaign_id,
           p_parent_id         => p_camp_rec.parent_Campaign_id
           );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF ;

   -- Following code is commented by ptendulk on 07-Feb-2001
   -- as there won't be any budget amount at campaigns level.
   -- ==========================================================
   -- Following code is added by ptendulk on 09/27/2000
   -- the code will convert the transaction currency in to
   -- functional currency.
   -- ==========================================================
   IF p_camp_rec.budget_amount_tc IS NOT NULL THEN
       IF p_camp_rec.budget_amount_tc <> FND_API.g_miss_num THEN
          AMS_CampaignRules_PVT.Convert_Camp_Currency(
             p_tc_curr     => l_camp_rec.transaction_currency_code,
             p_tc_amt      => l_camp_rec.budget_amount_tc,
             x_fc_curr     => l_camp_rec.functional_currency_code,
             x_fc_amt      => l_camp_rec.budget_amount_fc
             ) ;
      END IF ;
   ELSE
      l_camp_rec.budget_amount_fc := null ;
   END IF;


   -------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;

   -----------------------------------------------------------------
   -- budget_amount_tc, budget_amount_fc, media_type_code, media_id,
   -- channel_id are commented out by julou on 01/23/00
   -----------------------------------------------------------------
   UPDATE ams_campaigns_all_b SET
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      object_version_number = l_camp_rec.object_version_number + 1,
      owner_user_id = l_camp_rec.owner_user_id,
      active_flag = NVL(l_camp_rec.active_flag, 'Y'),
      private_flag = NVL(l_camp_rec.private_flag, 'N'),
      partner_flag = NVL(l_camp_rec.partner_flag, 'N'),
      template_flag = NVL(l_camp_rec.template_flag, 'N'),
      cascade_source_code_flag = NVL(l_camp_rec.cascade_source_code_flag, 'N'),
      inherit_attributes_flag = NVL(l_camp_rec.inherit_attributes_flag,'N'),
      source_code = l_camp_rec.source_code,
      rollup_type = l_camp_rec.rollup_type,
      campaign_type = l_camp_rec.campaign_type,
      media_type_code = l_camp_rec.media_type_code,
      priority = l_camp_rec.priority,
      fund_source_type = l_camp_rec.fund_source_type,
      fund_source_id = l_camp_rec.fund_source_id,
      parent_campaign_id = l_camp_rec.parent_campaign_id,
      application_id = l_camp_rec.application_id,
      qp_list_header_id = l_camp_rec.qp_list_header_id,
      media_id = l_camp_rec.media_id,
      channel_id = l_camp_rec.channel_id,
      event_type = l_camp_rec.event_type,
      arc_channel_from = l_camp_rec.arc_channel_from,
      dscript_name = l_camp_rec.dscript_name,
      transaction_currency_code = l_camp_rec.transaction_currency_code,
      functional_currency_code = l_camp_rec.functional_currency_code,
      budget_amount_tc = l_camp_rec.budget_amount_tc,
      budget_amount_fc = l_camp_rec.budget_amount_fc,
      forecasted_plan_start_date = l_camp_rec.forecasted_plan_start_date,
      forecasted_plan_end_date = l_camp_rec.forecasted_plan_end_date,
      forecasted_exec_start_date = l_camp_rec.forecasted_exec_start_date,
      forecasted_exec_end_date = l_camp_rec.forecasted_exec_end_date,
      actual_plan_start_date = l_camp_rec.actual_plan_start_date,
      actual_plan_end_date = l_camp_rec.actual_plan_end_date,
      actual_exec_start_date = l_camp_rec.actual_exec_start_date,
      actual_exec_end_date = l_camp_rec.actual_exec_end_date,
      inbound_url = l_camp_rec.inbound_url,
      inbound_email_id = l_camp_rec.inbound_email_id,
      inbound_phone_no = l_camp_rec.inbound_phone_no,
      duration = l_camp_rec.duration,
      duration_uom_code = l_camp_rec.duration_uom_code,
      ff_priority = l_camp_rec.ff_priority,
      ff_override_cover_letter = l_camp_rec.ff_override_cover_letter,
      ff_shipping_method = l_camp_rec.ff_shipping_method,
      ff_carrier = l_camp_rec.ff_carrier,
      content_source = l_camp_rec.content_source,
      cc_call_strategy = l_camp_rec.cc_call_strategy,
      cc_manager_user_id = l_camp_rec.cc_manager_user_id,
      forecasted_revenue = l_camp_rec.forecasted_revenue,
      actual_revenue = l_camp_rec.actual_revenue,
      forecasted_cost = l_camp_rec.forecasted_cost,
      actual_cost = l_camp_rec.actual_cost,
      forecasted_response = l_camp_rec.forecasted_response,
      actual_response = l_camp_rec.actual_response,
      target_response = l_camp_rec.target_response,
      country_code = l_camp_rec.country_code,
      language_code = l_camp_rec.language_code,
      attribute_category = l_camp_rec.attribute_category,
      attribute1 = l_camp_rec.attribute1,
      attribute2 = l_camp_rec.attribute2,
      attribute3 = l_camp_rec.attribute3,
      attribute4 = l_camp_rec.attribute4,
      attribute5 = l_camp_rec.attribute5,
      attribute6 = l_camp_rec.attribute6,
      attribute7 = l_camp_rec.attribute7,
      attribute8 = l_camp_rec.attribute8,
      attribute9 = l_camp_rec.attribute9,
      attribute10 = l_camp_rec.attribute10,
      attribute11 = l_camp_rec.attribute11,
      attribute12 = l_camp_rec.attribute12,
      attribute13 = l_camp_rec.attribute13,
      attribute14 = l_camp_rec.attribute14,
      attribute15 = l_camp_rec.attribute15,
      --version_no = l_camp_rec.version_no,
      campaign_calendar = l_camp_rec.campaign_calendar,
      start_period_name = l_camp_rec.start_period_name,
      end_period_name = l_camp_rec.end_period_name,
      city_id = l_camp_rec.city_id,
      global_flag = NVL(l_camp_rec.global_flag, 'N'),
      custom_setup_id = l_camp_rec.custom_setup_id,
      show_campaign_flag = NVL(l_camp_rec.show_campaign_flag, 'Y'),
      business_unit_id = l_camp_rec.business_unit_id,
      program_attribute_category = l_camp_rec.program_attribute_category,
      program_attribute1 = l_camp_rec.program_attribute1,
      program_attribute2 = l_camp_rec.program_attribute2,
      program_attribute3 = l_camp_rec.program_attribute3,
      program_attribute4 = l_camp_rec.program_attribute4,
      program_attribute5 = l_camp_rec.program_attribute5,
      program_attribute6 = l_camp_rec.program_attribute6,
      program_attribute7 = l_camp_rec.program_attribute7,
      program_attribute8 = l_camp_rec.program_attribute8,
      program_attribute9 = l_camp_rec.program_attribute9,
      program_attribute10 = l_camp_rec.program_attribute10,
      program_attribute11 = l_camp_rec.program_attribute11,
      program_attribute12 = l_camp_rec.program_attribute12,
      program_attribute13 = l_camp_rec.program_attribute13,
      program_attribute14 = l_camp_rec.program_attribute14,
      program_attribute15 = l_camp_rec.program_attribute15
      --Added by rrajesh on 04/13/01 - to update related_event_fields
      ,related_event_id = l_camp_rec.related_event_id
      ,related_event_from = l_camp_rec.related_event_from
      --end change 04/13/01 - related event
   WHERE campaign_id = l_camp_rec.campaign_id
   AND object_version_number = l_camp_rec.object_version_number;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   UPDATE ams_campaigns_all_tl SET
      campaign_name = l_camp_rec.campaign_name,
      campaign_theme = l_camp_rec.campaign_theme,
      description = l_camp_rec.description,
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE campaign_id = l_camp_rec.campaign_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -- create object association when channel is event
   --IF l_camp_rec.media_type_code = 'EVENTS' THEN
   --   AMS_CampaignRules_PVT.create_camp_association(
   --      l_camp_rec.campaign_id,
   --      l_camp_rec.channel_id,
   --      l_camp_rec.arc_channel_from,
   --      l_return_status
   --   );
   --   IF l_return_status = FND_API.g_ret_sts_error THEN
   --      RAISE FND_API.g_exc_error;
   --   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
   --      RAISE FND_API.g_exc_unexpected_error;
   --   END IF;
   --END IF;

   -- update campaign status through workflow
   AMS_CampaignRules_PVT.update_camp_status(
      l_camp_rec.campaign_id,
      l_camp_rec.user_status_id,
      l_camp_rec.budget_amount_tc,
      l_camp_rec.parent_campaign_id
   );

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
      ROLLBACK TO update_campaign;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_campaign;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO update_campaign;
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

END Update_Campaign;


--==================================================================
-- PROCEDURE
--    Validate_Campaign
--
-- NOTE
--
-- HISTORY
--   01-Oct-1999  holiu      Created.
--==================================================================
PROCEDURE validate_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  camp_rec_type
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_campaign';
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
      check_camp_items(
         p_camp_rec        => p_camp_rec,
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
      check_camp_record(
         p_camp_rec       => p_camp_rec,
         p_complete_rec   => p_camp_rec,
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
      check_camp_inter_entity(
         p_camp_rec        => p_camp_rec,
         p_complete_rec    => p_camp_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );
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

END validate_campaign;


--====================================================================
-- PROCEDURE
--    check_camp_req_items
--
-- NOTES
--    1. We don't check status_date and any flags.
--
-- HISTORY
--   01-Oct-1999   holiu      Created.
--   23-Jan-2001   julou      Added check for actual_exec_end_date
--   06-Feb-2001   ptendulk   Modified for Hornet.
--
--====================================================================

PROCEDURE check_camp_req_items(
   p_camp_rec       IN  camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ owner_user_id --------------------------
   IF p_camp_rec.owner_user_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CAMP_NO_OWNER_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   ------------------------ user_status_id --------------------------
   IF p_camp_rec.user_status_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CAMP_NO_USER_STATUS_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   ------------------------ rollup_type --------------------------
   IF p_camp_rec.rollup_type IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CAMP_NO_ROOLUP_TYPE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   ------------------------ application_id --------------------------
   IF p_camp_rec.application_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_NO_APPLICATION_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   ------------------------ campaign_name --------------------------
   IF p_camp_rec.campaign_name IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CAMP_NO_NAME');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   ------------------------ Start Date  --------------------------
   IF p_camp_rec.actual_exec_start_date IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CAMP_NO_START_DATE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;


END Check_Camp_Req_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_uk_items
--
-- HISTORY
--    10/01/99   holiu     Created.
--  07-Mar-2001  ptendulk  Moved the source code unique test in inter entitiy.
---------------------------------------------------------------------
PROCEDURE Check_Camp_Uk_Items(
   p_camp_rec        IN  camp_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_campaign, when campaign_id is passed in, we need to
   -- check if this campaign_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
   AND p_camp_rec.campaign_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
                             'ams_campaigns_all_b',
                             'campaign_id = ' || p_camp_rec.campaign_id
                             ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_DUPLICATE_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Camp_Uk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_fk_items
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE Check_Camp_Fk_Items(
   p_camp_rec        IN  camp_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_where_clause     VARCHAR2(4000);  -- Used by Check_FK_Exists.
   l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                VARCHAR2(30);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- owner_user_id ------------------------
   IF p_camp_rec.owner_user_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
--            'ams_jtf_rs_emp_v',
            'jtf_rs_resource_extns',
            'resource_id',
            p_camp_rec.owner_user_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_OWNER_USER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- application_id ------------------------
   IF p_camp_rec.application_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_application',
            'application_id',
            p_camp_rec.application_id
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_APPLICATION_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- qp_list_header_id ------------------------
   --IF p_camp_rec.qp_list_header_id <> FND_API.g_miss_num
   --   AND p_camp_rec.qp_list_header_id IS NOT NULL
   --THEN
   --   IF AMS_Utility_PVT.check_fk_exists(
   --        'qp_list_headers_b',
   --         'list_header_id',
   --         p_camp_rec.qp_list_header_id
   --      ) = FND_API.g_false
   --  THEN
   --      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
   --      THEN
   --         FND_MESSAGE.set_name('AMS', 'AMS_CAMP_BAD_QP_LIST_ID');
   --         FND_MSG_PUB.add;
   --      END IF;
   --      x_return_status := FND_API.g_ret_sts_error;
   --      RETURN;
   --   END IF;
   --END IF;

   --------------------- dscript_name ------------------------
   --IF p_camp_rec.dscript_name <> FND_API.g_miss_char
   --   AND p_camp_rec.dscript_name IS NOT NULL
   --THEN
   --   IF AMS_Utility_PVT.check_fk_exists(
   --         'ies_deployed_scripts',
   --         'dscript_name',
   --         p_camp_rec.dscript_name
   --      ) = FND_API.g_false
   --   THEN
   --      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
   --      THEN
   --         FND_MESSAGE.set_name('AMS', 'AMS_CAMP_BAD_DSCRIPT_NAME');
   --         FND_MSG_PUB.add;
   --      END IF;
   --      x_return_status := FND_API.g_ret_sts_error;
   --      RETURN;
   --   END IF;
   -- END IF;

   --------------------- custom_setup_id ----------------------------
   IF p_camp_rec.custom_setup_id <> FND_API.g_miss_num
      AND p_camp_rec.custom_setup_id IS NOT NULL
   THEN
      l_table_name              := 'ams_custom_setups_b' ;
      l_pk_name                 := 'custom_setup_id' ;
      l_pk_value                := p_camp_rec.custom_setup_id;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_where_clause            := ' object_type = '''||p_camp_rec.rollup_type ||'''' ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message('AMS_CAMP_BAD_CUSTOM_SETUP') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

   --------------------- city_id ----------------------------
   IF p_camp_rec.city_id <> FND_API.g_miss_num
      AND p_camp_rec.city_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'jtf_loc_hierarchies_b',
            'location_hierarchy_id',
            p_camp_rec.city_id,
            AMS_Utility_PVT.g_number,
            NULL
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_CITY');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- Task id  ----------------------------
   IF p_camp_rec.task_id <> FND_API.g_miss_num
      AND p_camp_rec.task_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'jtf_tasks_b',
            'task_id',
            p_camp_rec.task_id,
            AMS_Utility_PVT.g_number,
            NULL
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_TASK');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------- Language  ----------------------------
   IF p_camp_rec.language_code <> FND_API.g_miss_char
      AND p_camp_rec.language_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_languages',
            'language_code',
            p_camp_rec.language_code,
            AMS_Utility_PVT.g_varchar2,
            NULL
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_LANG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Camp_Fk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Camp_Lookup_Items
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE Check_Camp_Lookup_Items(
   p_camp_rec        IN  camp_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- rollup_type ------------------------
   IF p_camp_rec.rollup_type <> FND_API.g_miss_char
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_ROLLUP_TYPE',
            p_lookup_code => p_camp_rec.rollup_type
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_ROLLUP_TYPE') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

---------------------------------------------------------------------
-- 01/24/01  julou Commented out the following check as dont need media_type_code
---------------------------------------------------------------------
/*
   ----------------------- media_type ------------------------
   IF p_camp_rec.media_type_code <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_MEDIA_TYPE',
            p_lookup_code => p_camp_rec.media_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CAMP_BAD_MEDIA_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
   ----------------------- campaign_type ------------------------

   -- Following code is commented by ptendulk on 12-Feb-2001
   ----------------------- event_type ------------------------
   --IF p_camp_rec.event_type <> FND_API.g_miss_char
   --   AND p_camp_rec.event_type IS NOT NULL
   --THEN
   --   IF AMS_Utility_PVT.check_lookup_exists(
   --         p_lookup_type => 'AMS_EVENT_TYPE',
   --         p_lookup_code => p_camp_rec.event_type
   --      ) = FND_API.g_false
   --   THEN
   --      AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_EVENT_TYPE') ;
   --      x_return_status := FND_API.g_ret_sts_error;
   --      RETURN;
   --   END IF;
   --END IF;

   ----------------------- priority ------------------------
   IF p_camp_rec.priority <> FND_API.g_miss_char
      AND p_camp_rec.priority IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_PRIORITY',
            p_lookup_code => p_camp_rec.priority
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_PRIORITY') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- priority ------------------------
   IF p_camp_rec.priority <> FND_API.g_miss_char
      AND p_camp_rec.priority IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_PRIORITY',
            p_lookup_code => p_camp_rec.priority
         ) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_PRIORITY') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- Related Event from  ------------------------
   IF p_camp_rec.related_event_from <> FND_API.g_miss_char
      AND p_camp_rec.related_event_from IS NOT NULL
   THEN
      IF p_camp_rec.related_event_from <> 'EVEH' AND
         p_camp_rec.related_event_from <> 'EVEO'
	 --Added by rrajesh on 04/16/01 - EONE
         AND p_camp_rec.related_event_from <> 'EONE'
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_EVEH') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- Following line of code is Commented by ptendulk as it is no longer being used.
   ------------------ ff_shipping_method ------------------------
   --IF p_camp_rec.ff_shipping_method <> FND_API.g_miss_char
   --   AND p_camp_rec.ff_shipping_method IS NOT NULL
   --THEN
   --   IF AMS_Utility_PVT.check_lookup_exists(
   --         p_lookup_type => 'AMS_CAMP_FF_SHIP_METHOD',
   --         p_lookup_code => p_camp_rec.ff_shipping_method
   --      ) = FND_API.g_false
   --   THEN
   --      AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_FF_SHIP_METHOD') ;
   --      x_return_status := FND_API.g_ret_sts_error;
   --      RETURN;
   --   END IF;
   --END IF;

   ----------------------- cc_call_strategy ----------------------
   --IF p_camp_rec.cc_call_strategy <> FND_API.g_miss_char
   --   AND p_camp_rec.cc_call_strategy IS NOT NULL
   --THEN
   --   IF AMS_Utility_PVT.check_lookup_exists(
   --         p_lookup_type => 'AMS_CAMP_CALL_STRATEGY',
   --         p_lookup_code => p_camp_rec.cc_call_strategy
   --      ) = FND_API.g_false
   --   THEN
   --      AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_CC_CALL_STRATEGY') ;
   --      x_return_status := FND_API.g_ret_sts_error;
   --      RETURN;
   --   END IF;
   --END IF;

END Check_Camp_Lookup_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_flag_items
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE check_camp_flag_items(
   p_camp_rec        IN  camp_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- active_flag ------------------------
   IF p_camp_rec.active_flag <> FND_API.g_miss_char
      AND p_camp_rec.active_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_camp_rec.active_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_ACTIVE_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- private_flag ------------------------
   IF p_camp_rec.private_flag <> FND_API.g_miss_char
      AND p_camp_rec.private_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_camp_rec.private_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_PRIVATE_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- partner_flag ------------------------
   IF p_camp_rec.partner_flag <> FND_API.g_miss_char
      AND p_camp_rec.partner_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_camp_rec.partner_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_PARTNER_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- template_flag ------------------------
   IF p_camp_rec.template_flag <> FND_API.g_miss_char
      AND p_camp_rec.template_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_camp_rec.template_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_TEMPLATE_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_camp_rec.global_flag <> FND_API.g_miss_char
      AND p_camp_rec.global_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_camp_rec.global_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_GLOBAL_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_camp_rec.show_campaign_flag <> FND_API.g_miss_char
      AND p_camp_rec.show_campaign_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.Is_Y_Or_N(p_camp_rec.show_campaign_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_TEMPLATE_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   IF p_camp_rec.accounts_closed_flag <> FND_API.g_miss_char
      AND p_camp_rec.accounts_closed_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.Is_Y_Or_N(p_camp_rec.accounts_closed_flag) = FND_API.g_false
      THEN
         AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_ACC_CLOSED_FLAG');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   ------------------- cascade_source_code_flag -----------------------
   -- IF p_camp_rec.cascade_source_code_flag <> FND_API.g_miss_char
   --    AND p_camp_rec.cascade_source_code_flag IS NOT NULL
   -- THEN
   --    IF AMS_Utility_PVT.is_Y_or_N(p_camp_rec.cascade_source_code_flag)
   --      = FND_API.g_false
   --    THEN
   --      AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_CASCADE_FLAG');
   --      x_return_status := FND_API.g_ret_sts_error;
   --      RETURN;
   --    END IF;
   --END IF;

END Check_Camp_Flag_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Camp_Items
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE Check_Camp_Items(
   p_camp_rec        IN  camp_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   check_camp_req_items(
      p_camp_rec       => p_camp_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_camp_uk_items(
      p_camp_rec        => p_camp_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_camp_fk_items(
      p_camp_rec       => p_camp_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_camp_lookup_items(
      p_camp_rec        => p_camp_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_camp_flag_items(
      p_camp_rec        => p_camp_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Camp_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_record
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE check_camp_record(
   p_camp_rec       IN  camp_rec_type,
   p_complete_rec   IN  camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_parent_type IS
   SELECT rollup_type,status_code
     FROM ams_campaigns_all_b
    WHERE campaign_id = p_camp_rec.parent_campaign_id;

   l_parent_type VARCHAR2(30);
   l_status_code VARCHAR2(30);
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_camp_rec.campaign_type <> FND_API.g_miss_char
      AND p_camp_rec.campaign_type IS NOT NULL
   THEN
      IF p_complete_rec.rollup_type = 'RCAM' THEN
         IF AMS_Utility_PVT.check_lookup_exists(
               p_lookup_type => 'AMS_PROGRAM_OBJECTIVE',
               p_lookup_code => p_camp_rec.campaign_type
            ) = FND_API.g_false
         THEN
            AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_TYPE') ;
            x_return_status := FND_API.g_ret_sts_error;
         END IF;
      ELSE
         IF AMS_Utility_PVT.check_lookup_exists(
               p_lookup_type => 'AMS_CAMPAIGN_PURPOSE',
               p_lookup_code => p_camp_rec.campaign_type
            ) = FND_API.g_false
         THEN
            AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_TYPE') ;
            x_return_status := FND_API.g_ret_sts_error;
         END IF;
      END IF;
   END IF;

   -- budget amount must come with budget currency
   IF p_complete_rec.transaction_currency_code IS NULL
      AND p_complete_rec.budget_amount_tc IS NOT NULL
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CAMP_BUDGET_NO_CURRENCY');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;


--------------------------------------------------------------------
-- 01/23/01  julou  Added check parent type
--------------------------------------------------------------------
  -- check parent campaign type

   IF p_camp_rec.parent_campaign_id IS NOT NULL
      AND p_camp_rec.parent_campaign_id <> FND_API.g_miss_num
   THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.Debug_message('Parent Camp Id '||p_camp_rec.parent_campaign_id );
      END IF;
      OPEN c_parent_type;
      FETCH c_parent_type INTO l_parent_type, l_status_code;
      IF (c_parent_type%NOTFOUND) THEN
         CLOSE c_parent_type;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN

          FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
         END IF;
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.Debug_message('Error Here : ' ||p_camp_rec.parent_campaign_id );
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;
      CLOSE c_parent_type;

      IF l_parent_type <> 'RCAM'
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_CAMP_BAD_ROLLUP_TYPE');
          FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

      -- Can add component to Programs only when new and active
      -- Program-Campaign 1.
      IF l_status_code <> 'NEW' AND
         l_status_code <> 'ACTIVE'
      THEN
         AMS_Utility_Pvt.Error_Message('AMS_CAMP_PARENT_STAT');
         RAISE FND_API.g_exc_error;
      END IF ;

   END IF;

END Check_Camp_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_inter_entity
--
-- HISTORY
--    10/26/99  holiu     Created.
--  18-May-2001 ptendulk  Added return after error happens in api.
--                              Follow bug #1786801
--  21-May-2001 ptendulk  Added validation to check the duplicate name
--                        for Program.
--  01-Aug-2001 ptendulk  Changed the validation for the unique prog
---                       name. Removed call to utility check uniqueness.
--  25-Oct-2001 ptendulk  Added validation for the parent of the program.
--  29-jan-2003 soagrawa  Fixed bug# 2764007
---------------------------------------------------------------------
PROCEDURE check_camp_inter_entity(
   p_camp_rec        IN  camp_rec_type,
   p_complete_rec    IN  camp_rec_type,
   p_validation_mode IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

   l_return_status  VARCHAR2(1);
   l_start_date     DATE;
   l_end_date       DATE;

   l_table_name     VARCHAR2(100);
   l_pk_name        VARCHAR2(100);
   l_pk_value       NUMBER ;
   l_pk_data_type   VARCHAR2(30);
   l_where_clause   VARCHAR2(2000);

   CURSOR c_prog_name
   IS SELECT 1 from dual
      WHERE EXISTS ( SELECT * from ams_campaigns_vl
                     WHERE rollup_type = 'RCAM'
                     AND UPPER(campaign_name) = UPPER(p_complete_rec.campaign_name)) ;
   CURSOR c_prog_name_updt
   IS SELECT 1 from dual
      WHERE EXISTS ( SELECT * from ams_campaigns_vl
                     WHERE rollup_type = 'RCAM'
                     AND UPPER(campaign_name) = UPPER(p_complete_rec.campaign_name)
                     AND campaign_id <> p_complete_rec.campaign_id );

   l_dummy NUMBER ;

BEGIN

   -- For creating, check if source_code is unique in ams_source_codes.
   IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      IF p_complete_rec.rollup_type = 'RCAM' THEN
         IF p_camp_rec.source_code IS NULL THEN
            AMS_Utility_PVT.Error_Message('AMS_CAMP_NO_PROG_CODE');
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         ELSE

--aranka added 07/27/02
            IF AMS_Utility_PVT.check_uniqueness(
                                'ams_campaigns_all_b',
                                'source_code = ''' || p_camp_rec.source_code || ''''
--                                'source_code = ''' || p_camp_rec.source_code ||
--                                ''' AND rollup_type = ''RCAM'''
                                ) = FND_API.g_false
            THEN
               AMS_Utility_PVT.Error_Message('AMS_CAMP_BAD_PROG_CODE');
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;
         END IF;
      ELSE
         IF p_camp_rec.source_code IS NOT NULL THEN
            IF AMS_Utility_PVT.check_uniqueness(
                                'ams_source_codes',
                                'source_code = ''' || p_camp_rec.source_code ||
                                ''' AND active_flag = ''Y'''
                                ) = FND_API.g_false
            THEN
               AMS_Utility_PVT.Error_Message('AMS_CAMP_DUPLICATE_CODE');
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;

--aranka added 07/27/02
--sam added
            IF AMS_Utility_PVT.check_uniqueness(
                                'ams_campaigns_all_b',
                                'source_code = ''' || p_camp_rec.source_code || ''''
                                ) = FND_API.g_false
            THEN
               AMS_Utility_PVT.Error_Message('AMS_CAMP_DUPLICATE_CODE');
               x_return_status := FND_API.g_ret_sts_error;
               RETURN;
            END IF;


         END IF;
      END IF ;
   END IF;

   -- Following code is added by ptendulk on 21-May-2001
   -- Program name have to be unique.
   -- Please refer to bug #1783583
   -------------------------Program Name  ---------------------------------
   IF p_complete_rec.rollup_type = 'RCAM' THEN
      --IF p_validation_mode = JTF_PLSQL_API.g_create THEN
      --   IF AMS_Utility_PVT.check_uniqueness(
      --                       'ams_campaigns_vl',
      --                       'campaign_name = ''' || p_camp_rec.campaign_name ||
      --                       ''' AND rollup_type = ''RCAM'''
      --                       ) = FND_API.g_false
      --   THEN
      --      AMS_Utility_PVT.Error_Message('AMS_PROG_DUPLICATE_NAME');
      --      x_return_status := FND_API.g_ret_sts_error;
      --      RETURN;
      --   END IF;
      --ELSE
      --   IF AMS_Utility_PVT.check_uniqueness(
      --                       'ams_campaigns_vl',
      --                       'campaign_name = ''' || p_camp_rec.campaign_name ||
      --                       ''' AND rollup_type = ''RCAM'''||
      --                       ' AND campaign_id <> '||p_camp_rec.campaign_id
      --                       ) = FND_API.g_false
      --   THEN
      --      AMS_Utility_PVT.Error_Message('AMS_PROG_DUPLICATE_NAME');
      --      x_return_status := FND_API.g_ret_sts_error;
      --      RETURN;
      --   END IF;
      --END IF ;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         OPEN c_prog_name ;
         FETCH c_prog_name INTO l_dummy;
         CLOSE c_prog_name ;
      ELSE
         OPEN c_prog_name_updt ;
         FETCH c_prog_name_updt INTO l_dummy;
         CLOSE c_prog_name_updt ;
      END IF ;

      IF l_dummy IS NOT NULL THEN
         AMS_Utility_PVT.Error_Message('AMS_PROG_DUPLICATE_NAME');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF ;


   END IF ;

   ------------------------ actual_exec_end_date --------------------------
   IF p_camp_rec.actual_exec_end_date IS NOT NULL
   AND p_camp_rec.actual_exec_end_date <> FND_API.g_miss_date
   THEN
      IF p_complete_rec.rollup_type <> 'RCAM'
      AND p_camp_rec.actual_exec_end_date IS NULL
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_CAMP_NO_END_DATE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF ;

   ------------------------ Related Event  --------------------------
   IF (p_camp_rec.related_event_id IS NOT NULL AND p_camp_rec.related_event_id <> FND_API.g_miss_num)
   OR (p_camp_rec.related_event_from IS NOT NULL AND p_camp_rec.related_event_from <> FND_API.g_miss_char)
   THEN
      AMS_CampaignRules_PVT.validate_realted_event(
         p_related_event_id      => p_complete_rec.related_event_id ,
         p_related_event_type    => p_complete_rec.related_event_from,
         x_return_status         => x_return_status
      ) ;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         AMS_UTILITY_PVT.Error_Message('AMS_CAMP_INVALID_EVENT');
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF ;

      -- Following code is modified by ptendulk on 22-May-2001
      -- Call business rule api
      -- Get table_name and pk_name for the ARC qualifier.
      --AMS_Utility_PVT.Get_Qual_Table_Name_And_PK (
      --   p_sys_qual                     => p_complete_rec.related_event_from,
      --   x_return_status                => x_return_status,
      --   x_table_name                   => l_table_name,
      --   x_pk_name                      => l_pk_name
      --);

      --l_pk_value                 := p_complete_rec.related_event_id ;
      --l_pk_data_type             := AMS_Utility_PVT.G_NUMBER;
      --l_where_clause             := NULL;

      --IF AMS_Utility_PVT.Check_FK_Exists (
      --      p_table_name                   => l_table_name
      --     ,p_pk_name                      => l_pk_name
      --     ,p_pk_value                     => l_pk_value
      --     ,p_pk_data_type                 => l_pk_data_type
      --      ,p_additional_where_clause      => l_where_clause
      --   ) = FND_API.G_FALSE
      --THEN
      --   AMS_UTILITY_PVT.Error_Message('AMS_CAMP_INVALID_EVENT');
      --   x_return_status := FND_API.G_RET_STS_ERROR;
      --   RETURN;
      --END IF;

   END IF ;

   -- check if actual_exec_start_date <= actual_exec_end_date
   IF p_camp_rec.actual_exec_start_date IS NOT NULL
   AND p_camp_rec.actual_exec_start_date <> FND_API.g_miss_date
   AND p_camp_rec.actual_exec_end_date IS NOT null
   AND p_camp_rec.actual_exec_end_date <> FND_API.g_miss_date
   THEN
      l_start_date := p_complete_rec.actual_exec_start_date;
      l_end_date := p_complete_rec.actual_exec_end_date;

      IF l_start_date > l_end_date THEN
         AMS_UTILITY_PVT.Error_Message('AMS_CAMP_START_AFTER_END');
         x_return_status := FND_API.g_ret_sts_error;
         -- Following line is added by ptendulk on 18-May-2001
         -- Refer bug #1786801
         RETURN;
      END IF;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------- check template flag ----------------------
   AMS_CampaignRules_PVT.Check_Camp_Template_Flag(
      p_complete_rec.parent_campaign_id,
      p_complete_rec.channel_id,
      p_complete_rec.template_flag,
      p_complete_rec.status_code,
      p_complete_rec.rollup_type,
      p_complete_rec.media_type_code,
      l_return_status
   );
   IF l_return_status <> FND_API.g_ret_sts_success THEN
      x_return_status := l_return_status;
      RETURN;
   END IF;

   -- Following validation is commented out by ptendulk on 07-Feb-2001
   -- as Activity and Marketing mediums are attached at the schedule
   -- level from Hornet release.
   ------------------- check media type ----------------------
   --   IF p_camp_rec.parent_campaign_id <> FND_API.g_miss_num
   --      OR p_camp_rec.rollup_type <> FND_API.g_miss_char
   --      OR p_camp_rec.media_type_code <> FND_API.g_miss_char
   --      OR p_camp_rec.media_id <> FND_API.g_miss_num
   --      OR p_camp_rec.channel_id <> FND_API.g_miss_num
   --      OR p_camp_rec.event_type <> FND_API.g_miss_char
   --      OR p_camp_rec.arc_channel_from <> FND_API.g_miss_char
   --   THEN
   --      AMS_CampaignRules_PVT.check_camp_media_type(
   --         p_camp_rec.campaign_id,
   --         p_complete_rec.parent_campaign_id,
   --         p_complete_rec.rollup_type,
   --         p_complete_rec.media_type_code,
   --         p_complete_rec.media_id,
   --         p_complete_rec.channel_id,
   --         p_complete_rec.event_type,
   --         p_complete_rec.arc_channel_from,
   --         l_return_status
   --      );
   --      l_return_status := FND_API.g_ret_sts_success ;
   --      IF l_return_status <> FND_API.g_ret_sts_success THEN
   --         x_return_status := l_return_status;
   --      END IF;
   --   END IF;

   ------------------- check fund source ----------------------
   -- 30-OCT-2000 holiu: remove as no longer needed
   -- IF p_camp_rec.fund_source_type <> FND_API.g_miss_char
   --   OR p_camp_rec.fund_source_id <> FND_API.g_miss_num
   -- THEN
   --    AMS_CampaignRules_PVT.check_camp_fund_source(
   --       p_complete_rec.fund_source_type,
   --       p_complete_rec.fund_source_id,
   --       l_return_status
   --    );
   --    IF l_return_status <> FND_API.g_ret_sts_success THEN
   --       x_return_status := l_return_status;
   --    END IF;
   -- END IF;

   ------------------- check calendar ----------------------
   IF p_camp_rec.campaign_calendar <> FND_API.g_miss_char
      OR p_camp_rec.start_period_name <> FND_API.g_miss_char
      OR p_camp_rec.end_period_name <> FND_API.g_miss_char
      OR p_camp_rec.actual_exec_start_date <> FND_API.g_miss_date
      OR p_camp_rec.actual_exec_end_date <> FND_API.g_miss_date
   THEN
      AMS_CampaignRules_PVT.check_camp_calendar(
         p_complete_rec.campaign_calendar,
         p_complete_rec.start_period_name,
         p_complete_rec.end_period_name,
         p_complete_rec.actual_exec_start_date,
         p_complete_rec.actual_exec_end_date,
         l_return_status
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         x_return_status := l_return_status;
         RETURN;
      END IF;
   END IF;

   -- soagrawa 29-jan-2003  bug# 2764007
   IF p_complete_rec.rollup_type <> 'RCAM'
   THEN
      ------------------- check version ----------------------
      IF p_camp_rec.campaign_name <> FND_API.g_miss_char
         OR p_camp_rec.status_code <> FND_API.g_miss_char
         OR p_camp_rec.actual_exec_start_date <> FND_API.g_miss_date
         OR p_camp_rec.city_id <> FND_API.g_miss_num
         -- 25-Aug-2005 mayjain version is no longer supported from R12
         --OR p_camp_rec.version_no <> FND_API.g_miss_num
      THEN
         AMS_CampaignRules_PVT.check_camp_version(
            p_complete_rec.campaign_id,
            p_complete_rec.campaign_name,
            p_complete_rec.status_code,
            p_complete_rec.actual_exec_start_date,
            p_complete_rec.city_id,
            p_complete_rec.version_no,
            l_return_status
         );
         IF l_return_status <> FND_API.g_ret_sts_success THEN
            x_return_status := l_return_status;
            RETURN ;
         END IF;
      END IF;
   END IF;

   -- Following code is modified by ptendulk on 09-Sep-2001
   --  Business units of parent and child can be different.
   --  Refer bug #1966445
   -- Check the business unit id
   --IF p_camp_rec.business_unit_id IS NOT NULL
   ---AND p_camp_rec.business_unit_id <> FND_API.g_miss_num  THEN

   --   AMS_CampaignRules_PVT.Check_BU_Vs_Child(p_complete_rec.campaign_id ,
   --                                           p_complete_rec.business_unit_id,
   --                                           l_return_status);

   --   IF l_return_status <> FND_API.g_ret_sts_success THEN
   --      x_return_status := l_return_status;
   --      RETURN ;
   --   END IF;

   --   IF p_complete_rec.parent_campaign_id IS NOT NULL THEN
   --      AMS_CampaignRules_PVT.Check_BU_Vs_parent(p_complete_rec.parent_campaign_id ,
   --                                              p_complete_rec.business_unit_id,
   --                                              l_return_status);

   --      IF l_return_status <> FND_API.g_ret_sts_success THEN
   --         x_return_status := l_return_status;
   --         RETURN ;
   --      END IF;
   --   END IF ;

   --END IF ;


   ------------------- Parent Status ------------------------------
      AMS_CampaignRules_PVT.check_camp_status_vs_parent(
         p_complete_rec.parent_campaign_id,
         p_complete_rec.status_code,
         l_return_status
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         x_return_status := l_return_status;
         RETURN ;
      END IF;

   ------------------- check dates ------------------------------
   -- Following code is modified by ptendulk on 16-Jun-2001
   -- Refer Bug #1827117 as from program component screen dates will come
   -- as g_miss_date
   --IF p_camp_rec.actual_exec_start_date <> FND_API.g_miss_date
   --   OR p_camp_rec.actual_exec_end_date <> FND_API.g_miss_date
   --THEN
--  09-Aug-2002 aranka
      AMS_CampaignRules_PVT.check_camp_dates_vs_parent(
         p_complete_rec.parent_campaign_id,
         p_complete_rec.rollup_type,
         p_complete_rec.actual_exec_start_date,
         p_complete_rec.actual_exec_end_date,
         l_return_status
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         x_return_status := l_return_status;
         RETURN ;
      END IF;


      IF p_validation_mode = JTF_PLSQL_API.g_update AND
         p_complete_rec.rollup_type = 'RCAM'
      THEN
         AMS_CampaignRules_PVT.check_camp_dates_vs_child(
            p_complete_rec.campaign_id,
            p_complete_rec.actual_exec_start_date,
            p_complete_rec.actual_exec_end_date,
            l_return_status
         );
         IF l_return_status <> FND_API.g_ret_sts_success THEN
            x_return_status := l_return_status;
            RETURN;
         END IF;
      END IF;

      IF  p_validation_mode = JTF_PLSQL_API.g_update
      AND p_complete_rec.rollup_type <> 'RCAM'
      THEN
         AMS_CampaignRules_PVT.check_camp_dates_vs_csch(
            p_complete_rec.campaign_id,
            p_complete_rec.actual_exec_start_date,
            p_complete_rec.actual_exec_end_date,
            l_return_status
         );
         IF l_return_status <> FND_API.g_ret_sts_success THEN
            x_return_status := l_return_status;
            RETURN ;
         END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_update THEN
         IF p_complete_rec.rollup_type = 'RCAM' THEN
            AMS_CampaignRules_PVT.Check_Prog_Dates_Vs_Eveh(
               p_complete_rec.campaign_id,
               p_complete_rec.actual_exec_start_date,
               p_complete_rec.actual_exec_end_date,
               l_return_status
            );
            IF l_return_status <> FND_API.g_ret_sts_success THEN
               x_return_status := l_return_status;
               RETURN ;
            END IF;
         END IF;
      END IF;
   --END IF;

   IF p_complete_rec.rollup_type = 'RCAM' THEN
      IF p_camp_rec.parent_campaign_id IS NOT NULL AND
         p_camp_rec.parent_campaign_id <> FND_API.G_MISS_NUM
      THEN
         AMS_CampaignRules_PVT.Check_Children_Tree( p_campaign_id          =>   p_complete_rec.campaign_id,
                                                   p_parent_campaign_id   =>   p_complete_rec.parent_campaign_id) ;
      END IF ;

   END IF ;

END Check_Camp_Inter_Entity;


---------------------------------------------------------------------
-- PROCEDURE
--    init_camp_rec
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE init_camp_rec(
   x_camp_rec  OUT NOCOPY  camp_rec_type
)
IS
BEGIN

   x_camp_rec.campaign_id := FND_API.g_miss_num;
   x_camp_rec.last_update_date := FND_API.g_miss_date;
   x_camp_rec.last_updated_by := FND_API.g_miss_num;
   x_camp_rec.creation_date := FND_API.g_miss_date;
   x_camp_rec.created_by := FND_API.g_miss_num;
   x_camp_rec.last_update_login := FND_API.g_miss_num;
   x_camp_rec.object_version_number := FND_API.g_miss_num;
   x_camp_rec.owner_user_id := FND_API.g_miss_num;
   x_camp_rec.user_status_id := FND_API.g_miss_num;
   x_camp_rec.status_code := FND_API.g_miss_char;
   x_camp_rec.status_date := FND_API.g_miss_date;
   x_camp_rec.active_flag := FND_API.g_miss_char;
   x_camp_rec.private_flag := FND_API.g_miss_char;
   x_camp_rec.partner_flag := FND_API.g_miss_char;
   x_camp_rec.template_flag := FND_API.g_miss_char;
   x_camp_rec.cascade_source_code_flag := FND_API.g_miss_char;
   x_camp_rec.inherit_attributes_flag := FND_API.g_miss_char;
   x_camp_rec.source_code := FND_API.g_miss_char;
   x_camp_rec.rollup_type := FND_API.g_miss_char;
   x_camp_rec.campaign_type := FND_API.g_miss_char;
   --x_camp_rec.media_type_code := FND_API.g_miss_char;
   x_camp_rec.priority := FND_API.g_miss_char;
   x_camp_rec.fund_source_type := FND_API.g_miss_char;
   x_camp_rec.fund_source_id := FND_API.g_miss_num;
   x_camp_rec.parent_campaign_id := FND_API.g_miss_num;
   x_camp_rec.application_id := FND_API.g_miss_num;
   --x_camp_rec.media_id := FND_API.g_miss_num;
   --x_camp_rec.channel_id := FND_API.g_miss_num;
   x_camp_rec.event_type := FND_API.g_miss_char;
   x_camp_rec.arc_channel_from := FND_API.g_miss_char;
   x_camp_rec.dscript_name := FND_API.g_miss_char;
   x_camp_rec.transaction_currency_code := FND_API.g_miss_char;
   x_camp_rec.functional_currency_code := FND_API.g_miss_char;
   x_camp_rec.budget_amount_tc := FND_API.g_miss_num;
   x_camp_rec.budget_amount_fc := FND_API.g_miss_num;
   x_camp_rec.forecasted_plan_start_date := FND_API.g_miss_date;
   x_camp_rec.forecasted_plan_end_date := FND_API.g_miss_date;
   x_camp_rec.forecasted_exec_start_date := FND_API.g_miss_date;
   x_camp_rec.forecasted_exec_end_date := FND_API.g_miss_date;
   x_camp_rec.actual_plan_start_date := FND_API.g_miss_date;
   x_camp_rec.actual_plan_end_date := FND_API.g_miss_date;
   x_camp_rec.actual_exec_start_date := FND_API.g_miss_date;
   x_camp_rec.actual_exec_end_date := FND_API.g_miss_date;
   x_camp_rec.inbound_url := FND_API.g_miss_char;
   x_camp_rec.inbound_email_id := FND_API.g_miss_char;
   x_camp_rec.inbound_phone_no := FND_API.g_miss_char;
   x_camp_rec.duration := FND_API.g_miss_num;
   x_camp_rec.duration_uom_code := FND_API.g_miss_char;
   x_camp_rec.ff_priority := FND_API.g_miss_char;
   x_camp_rec.ff_override_cover_letter := FND_API.g_miss_num;
   x_camp_rec.ff_shipping_method := FND_API.g_miss_char;
   x_camp_rec.ff_carrier := FND_API.g_miss_char;
   x_camp_rec.content_source := FND_API.g_miss_char;
   x_camp_rec.cc_call_strategy := FND_API.g_miss_char;
   x_camp_rec.cc_manager_user_id := FND_API.g_miss_num;
   x_camp_rec.forecasted_revenue := FND_API.g_miss_num;
   x_camp_rec.actual_revenue := FND_API.g_miss_num;
   x_camp_rec.forecasted_cost := FND_API.g_miss_num;
   x_camp_rec.actual_cost := FND_API.g_miss_num;
   x_camp_rec.forecasted_response := FND_API.g_miss_num;
   x_camp_rec.actual_response := FND_API.g_miss_num;
   x_camp_rec.target_response := FND_API.g_miss_num;
   x_camp_rec.country_code := FND_API.g_miss_char;
   x_camp_rec.language_code := FND_API.g_miss_char;
   x_camp_rec.attribute_category := FND_API.g_miss_char;
   x_camp_rec.attribute1 := FND_API.g_miss_char;
   x_camp_rec.attribute2 := FND_API.g_miss_char;
   x_camp_rec.attribute3 := FND_API.g_miss_char;
   x_camp_rec.attribute4 := FND_API.g_miss_char;
   x_camp_rec.attribute5 := FND_API.g_miss_char;
   x_camp_rec.attribute6 := FND_API.g_miss_char;
   x_camp_rec.attribute7 := FND_API.g_miss_char;
   x_camp_rec.attribute8 := FND_API.g_miss_char;
   x_camp_rec.attribute9 := FND_API.g_miss_char;
   x_camp_rec.attribute10 := FND_API.g_miss_char;
   x_camp_rec.attribute11 := FND_API.g_miss_char;
   x_camp_rec.attribute12 := FND_API.g_miss_char;
   x_camp_rec.attribute13 := FND_API.g_miss_char;
   x_camp_rec.attribute14 := FND_API.g_miss_char;
   x_camp_rec.attribute15 := FND_API.g_miss_char;
   x_camp_rec.campaign_name := FND_API.g_miss_char;
   x_camp_rec.campaign_theme := FND_API.g_miss_char;
   x_camp_rec.description := FND_API.g_miss_char;
   x_camp_rec.version_no := FND_API.g_miss_num;
   x_camp_rec.campaign_calendar := FND_API.g_miss_char;
   x_camp_rec.start_period_name := FND_API.g_miss_char;
   x_camp_rec.end_period_name := FND_API.g_miss_char;
   x_camp_rec.city_id := FND_API.g_miss_num;
   x_camp_rec.global_flag := FND_API.g_miss_char;
   x_camp_rec.custom_setup_id := FND_API.g_miss_num;
   x_camp_rec.show_campaign_flag := FND_API.g_miss_char;
   x_camp_rec.business_unit_id := FND_API.g_miss_num;
   x_camp_rec.task_id          := FND_API.g_miss_num;
   x_camp_rec.accounts_closed_flag := FND_API.g_miss_char;
   x_camp_rec.related_event_from := FND_API.g_miss_char;
   x_camp_rec.related_event_id := FND_API.g_miss_num;
   x_camp_rec.program_attribute_category := FND_API.g_miss_char;
   x_camp_rec.program_attribute1 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute2 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute3 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute4 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute5 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute6 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute7 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute8 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute9 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute10 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute11 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute12 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute13 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute14 := FND_API.g_miss_char ;
   x_camp_rec.program_attribute15 := FND_API.g_miss_char ;




END init_camp_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    complete_camp_rec
--
-- HISTORY
--    10/01/99  holiu  Created.
---------------------------------------------------------------------
PROCEDURE complete_camp_rec(
   p_camp_rec      IN  camp_rec_type,
   x_complete_rec  OUT NOCOPY camp_rec_type
)
IS

   CURSOR c_camp IS
   SELECT *
     FROM ams_campaigns_vl
    WHERE campaign_id = p_camp_rec.campaign_id;

   l_camp_rec  c_camp%ROWTYPE;

BEGIN

   x_complete_rec := p_camp_rec;

   OPEN c_camp;
   FETCH c_camp INTO l_camp_rec;
   IF c_camp%NOTFOUND THEN
      CLOSE c_camp;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_camp;

   IF p_camp_rec.owner_user_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_user_id := l_camp_rec.owner_user_id;
   END IF;

   IF p_camp_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_camp_rec.user_status_id;
   END IF;

   -- status_code will go with user_status_id
   x_complete_rec.status_code := AMS_Utility_PVT.get_system_status_code(
	 x_complete_rec.user_status_id
   );

   IF p_camp_rec.status_date = FND_API.g_miss_date
      OR p_camp_rec.status_date IS NULL
   THEN
      IF p_camp_rec.user_status_id = l_camp_rec.user_status_id THEN
      -- no status change, set it to be the original value
         x_complete_rec.status_date := l_camp_rec.status_date;
      ELSE
      -- status changed, set it to be SYSDATE
         x_complete_rec.status_date := SYSDATE;
      END IF;
   END IF;

   IF p_camp_rec.active_flag = FND_API.g_miss_char THEN
      x_complete_rec.active_flag := l_camp_rec.active_flag;
   END IF;

   IF p_camp_rec.private_flag = FND_API.g_miss_char THEN
      x_complete_rec.private_flag := l_camp_rec.private_flag;
   END IF;

   IF p_camp_rec.partner_flag = FND_API.g_miss_char THEN
      x_complete_rec.partner_flag := l_camp_rec.partner_flag;
   END IF;

   IF p_camp_rec.template_flag = FND_API.g_miss_char THEN
      x_complete_rec.template_flag := l_camp_rec.template_flag;
   END IF;

   IF p_camp_rec.cascade_source_code_flag = FND_API.g_miss_char THEN
      x_complete_rec.cascade_source_code_flag := l_camp_rec.cascade_source_code_flag;
   END IF;

   IF p_camp_rec.inherit_attributes_flag = FND_API.g_miss_char THEN
      x_complete_rec.inherit_attributes_flag := l_camp_rec.inherit_attributes_flag;
   END IF;

   IF p_camp_rec.source_code = FND_API.g_miss_char THEN
      x_complete_rec.source_code := l_camp_rec.source_code;
   END IF;

   IF p_camp_rec.rollup_type = FND_API.g_miss_char THEN
      x_complete_rec.rollup_type := l_camp_rec.rollup_type;
   END IF;

   IF p_camp_rec.campaign_type = FND_API.g_miss_char THEN
      x_complete_rec.campaign_type := l_camp_rec.campaign_type;
   END IF;

   IF p_camp_rec.media_type_code = FND_API.g_miss_char THEN
      x_complete_rec.media_type_code := l_camp_rec.media_type_code;
   END IF;

   IF p_camp_rec.priority = FND_API.g_miss_char THEN
      x_complete_rec.priority := l_camp_rec.priority;
   END IF;

   IF p_camp_rec.fund_source_type = FND_API.g_miss_char THEN
      x_complete_rec.fund_source_type := l_camp_rec.fund_source_type;
   END IF;

   IF p_camp_rec.fund_source_id = FND_API.g_miss_num THEN
      x_complete_rec.fund_source_id := l_camp_rec.fund_source_id;
   END IF;

   IF p_camp_rec.parent_campaign_id = FND_API.g_miss_num THEN
      x_complete_rec.parent_campaign_id := l_camp_rec.parent_campaign_id;
   END IF;

   IF p_camp_rec.application_id = FND_API.g_miss_num THEN
      x_complete_rec.application_id := l_camp_rec.application_id;
   END IF;

   IF p_camp_rec.qp_list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.qp_list_header_id := l_camp_rec.qp_list_header_id;
   END IF;

   IF p_camp_rec.media_id = FND_API.g_miss_num THEN
      x_complete_rec.media_id := l_camp_rec.media_id;
   END IF;

   IF p_camp_rec.channel_id = FND_API.g_miss_num THEN
      x_complete_rec.channel_id := l_camp_rec.channel_id;
   END IF;

   IF p_camp_rec.event_type = FND_API.g_miss_char THEN
      x_complete_rec.event_type := l_camp_rec.event_type;
   END IF;

   IF p_camp_rec.arc_channel_from = FND_API.g_miss_char THEN
      x_complete_rec.arc_channel_from := l_camp_rec.arc_channel_from;
   END IF;

   IF p_camp_rec.dscript_name = FND_API.g_miss_char THEN
      x_complete_rec.dscript_name := l_camp_rec.dscript_name;
   END IF;

   IF p_camp_rec.transaction_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.transaction_currency_code := l_camp_rec.transaction_currency_code;
   END IF;

   IF p_camp_rec.functional_currency_code = FND_API.g_miss_char THEN
      x_complete_rec.functional_currency_code := l_camp_rec.functional_currency_code;
   END IF;

   IF p_camp_rec.budget_amount_tc = FND_API.g_miss_num THEN
      x_complete_rec.budget_amount_tc := l_camp_rec.budget_amount_tc;
   END IF;

   IF p_camp_rec.budget_amount_fc = FND_API.g_miss_num THEN
      x_complete_rec.budget_amount_fc := l_camp_rec.budget_amount_fc;
   END IF;

   IF p_camp_rec.forecasted_plan_start_date = FND_API.g_miss_date THEN
      x_complete_rec.forecasted_plan_start_date := l_camp_rec.forecasted_plan_start_date;
   END IF;

   IF p_camp_rec.forecasted_plan_end_date = FND_API.g_miss_date THEN
      x_complete_rec.forecasted_plan_end_date := l_camp_rec.forecasted_plan_end_date;
   END IF;

   IF p_camp_rec.forecasted_exec_start_date = FND_API.g_miss_date THEN
      x_complete_rec.forecasted_exec_start_date := l_camp_rec.forecasted_exec_start_date;
   END IF;

   IF p_camp_rec.forecasted_exec_end_date = FND_API.g_miss_date THEN
      x_complete_rec.forecasted_exec_end_date := l_camp_rec.forecasted_exec_end_date;
   END IF;

   IF p_camp_rec.actual_plan_start_date = FND_API.g_miss_date THEN
      x_complete_rec.actual_plan_start_date := l_camp_rec.actual_plan_start_date;
   END IF;

   IF p_camp_rec.actual_plan_end_date = FND_API.g_miss_date THEN
      x_complete_rec.actual_plan_end_date := l_camp_rec.actual_plan_end_date;
   END IF;

   IF p_camp_rec.actual_exec_start_date = FND_API.g_miss_date THEN
      x_complete_rec.actual_exec_start_date := l_camp_rec.actual_exec_start_date;
   END IF;

   IF p_camp_rec.actual_exec_end_date = FND_API.g_miss_date THEN
      x_complete_rec.actual_exec_end_date := l_camp_rec.actual_exec_end_date;
   END IF;

   IF p_camp_rec.inbound_url = FND_API.g_miss_char THEN
      x_complete_rec.inbound_url := l_camp_rec.inbound_url;
   END IF;

   IF p_camp_rec.inbound_email_id = FND_API.g_miss_char THEN
      x_complete_rec.inbound_email_id := l_camp_rec.inbound_email_id;
   END IF;

   IF p_camp_rec.inbound_phone_no = FND_API.g_miss_char THEN
      x_complete_rec.inbound_phone_no := l_camp_rec.inbound_phone_no;
   END IF;

   IF p_camp_rec.duration = FND_API.g_miss_num THEN
      x_complete_rec.duration := l_camp_rec.duration;
   END IF;

   IF p_camp_rec.duration_uom_code = FND_API.g_miss_char THEN
      x_complete_rec.duration_uom_code := l_camp_rec.duration_uom_code;
   END IF;

   IF p_camp_rec.ff_priority = FND_API.g_miss_char THEN
      x_complete_rec.ff_priority := l_camp_rec.ff_priority;
   END IF;

   IF p_camp_rec.ff_override_cover_letter = FND_API.g_miss_num THEN
      x_complete_rec.ff_override_cover_letter := l_camp_rec.ff_override_cover_letter;
   END IF;

   IF p_camp_rec.ff_shipping_method = FND_API.g_miss_char THEN
      x_complete_rec.ff_shipping_method := l_camp_rec.ff_shipping_method;
   END IF;

   IF p_camp_rec.ff_carrier = FND_API.g_miss_char THEN
      x_complete_rec.ff_carrier := l_camp_rec.ff_carrier;
   END IF;

   IF p_camp_rec.content_source = FND_API.g_miss_char THEN
      x_complete_rec.content_source := l_camp_rec.content_source;
   END IF;

   IF p_camp_rec.cc_call_strategy = FND_API.g_miss_char THEN
      x_complete_rec.cc_call_strategy := l_camp_rec.cc_call_strategy;
   END IF;

   IF p_camp_rec.cc_manager_user_id = FND_API.g_miss_num THEN
      x_complete_rec.cc_manager_user_id := l_camp_rec.cc_manager_user_id;
   END IF;

   IF p_camp_rec.forecasted_revenue = FND_API.g_miss_num THEN
      x_complete_rec.forecasted_revenue := l_camp_rec.forecasted_revenue;
   END IF;

   IF p_camp_rec.actual_revenue = FND_API.g_miss_num THEN
      x_complete_rec.actual_revenue := l_camp_rec.actual_revenue;
   END IF;

   IF p_camp_rec.forecasted_cost = FND_API.g_miss_num THEN
      x_complete_rec.forecasted_cost := l_camp_rec.forecasted_cost;
   END IF;

   IF p_camp_rec.actual_cost = FND_API.g_miss_num THEN
      x_complete_rec.actual_cost := l_camp_rec.actual_cost;
   END IF;

   IF p_camp_rec.forecasted_response = FND_API.g_miss_num THEN
      x_complete_rec.forecasted_response := l_camp_rec.forecasted_response;
   END IF;

   IF p_camp_rec.actual_response = FND_API.g_miss_num THEN
      x_complete_rec.actual_response := l_camp_rec.actual_response;
   END IF;

   IF p_camp_rec.target_response = FND_API.g_miss_num THEN
      x_complete_rec.target_response := l_camp_rec.target_response;
   END IF;

   IF p_camp_rec.country_code = FND_API.g_miss_char THEN
      x_complete_rec.country_code := l_camp_rec.country_code;
   END IF;

   IF p_camp_rec.language_code = FND_API.g_miss_char THEN
      x_complete_rec.language_code := l_camp_rec.language_code;
   END IF;

   IF p_camp_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_camp_rec.attribute_category;
   END IF;

   IF p_camp_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_camp_rec.attribute1;
   END IF;

   IF p_camp_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_camp_rec.attribute2;
   END IF;

   IF p_camp_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_camp_rec.attribute3;
   END IF;

   IF p_camp_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_camp_rec.attribute4;
   END IF;

   IF p_camp_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_camp_rec.attribute5;
   END IF;

   IF p_camp_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_camp_rec.attribute6;
   END IF;

   IF p_camp_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_camp_rec.attribute7;
   END IF;

   IF p_camp_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_camp_rec.attribute8;
   END IF;

   IF p_camp_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_camp_rec.attribute9;
   END IF;

   IF p_camp_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_camp_rec.attribute10;
   END IF;

   IF p_camp_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_camp_rec.attribute11;
   END IF;

   IF p_camp_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_camp_rec.attribute12;
   END IF;

   IF p_camp_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_camp_rec.attribute13;
   END IF;

   IF p_camp_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_camp_rec.attribute14;
   END IF;

   IF p_camp_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_camp_rec.attribute15;
   END IF;

   IF p_camp_rec.campaign_name = FND_API.g_miss_char THEN
      x_complete_rec.campaign_name := l_camp_rec.campaign_name;
   END IF;

   IF p_camp_rec.campaign_theme = FND_API.g_miss_char THEN
      x_complete_rec.campaign_theme := l_camp_rec.campaign_theme;
   END IF;

   IF p_camp_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_camp_rec.description;
   END IF;

   IF p_camp_rec.version_no = FND_API.g_miss_num THEN
      x_complete_rec.version_no := l_camp_rec.version_no;
   END IF;

   IF p_camp_rec.campaign_calendar = FND_API.g_miss_char THEN
      x_complete_rec.campaign_calendar := l_camp_rec.campaign_calendar;
   END IF;

   IF p_camp_rec.start_period_name = FND_API.g_miss_char THEN
      x_complete_rec.start_period_name := l_camp_rec.start_period_name;
   END IF;

   IF p_camp_rec.end_period_name = FND_API.g_miss_char THEN
      x_complete_rec.end_period_name := l_camp_rec.end_period_name;
   END IF;

   IF p_camp_rec.city_id = FND_API.g_miss_num THEN
      x_complete_rec.city_id := l_camp_rec.city_id;
   END IF;

   IF p_camp_rec.global_flag = FND_API.g_miss_char THEN
      x_complete_rec.global_flag := l_camp_rec.global_flag;
   END IF;

   IF p_camp_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := l_camp_rec.custom_setup_id;
   END IF;

   IF p_camp_rec.show_campaign_flag = FND_API.g_miss_char THEN
      x_complete_rec.show_campaign_flag := l_camp_rec.show_campaign_flag;
   END IF;

   IF p_camp_rec.business_unit_id = FND_API.g_miss_num THEN
      x_complete_rec.business_unit_id := l_camp_rec.business_unit_id;
   END IF;

   IF p_camp_rec.accounts_closed_flag = FND_API.g_miss_char THEN
      x_complete_rec.accounts_closed_flag := l_camp_rec.accounts_closed_flag;
   END IF;

   IF p_camp_rec.task_id = FND_API.g_miss_num THEN
      x_complete_rec.task_id := l_camp_rec.task_id;
   END IF;

   IF p_camp_rec.related_event_from = FND_API.g_miss_char THEN
      x_complete_rec.related_event_from := l_camp_rec.related_event_from ;
   END IF;

   IF p_camp_rec.related_event_id = FND_API.g_miss_num THEN
      x_complete_rec.related_event_id := l_camp_rec.related_event_id;
   END IF;

   IF p_camp_rec.program_attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute_category := l_camp_rec.program_attribute_category;
   END IF;

   IF p_camp_rec.program_attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute1 := l_camp_rec.program_attribute1;
   END IF;

   IF p_camp_rec.program_attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute2 := l_camp_rec.program_attribute2;
   END IF;

   IF p_camp_rec.program_attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute3 := l_camp_rec.program_attribute3 ;
   END IF;

   IF p_camp_rec.program_attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute4 := l_camp_rec.program_attribute4 ;
   END IF;

   IF p_camp_rec.program_attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute5 := l_camp_rec.program_attribute5;
   END IF;

   IF p_camp_rec.program_attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute6 := l_camp_rec.program_attribute6;
   END IF;

   IF p_camp_rec.program_attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute7 := l_camp_rec.program_attribute7;
   END IF;

   IF p_camp_rec.program_attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute8 := l_camp_rec.program_attribute8;
   END IF;

   IF p_camp_rec.program_attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute9 := l_camp_rec.program_attribute9;
   END IF;

   IF p_camp_rec.program_attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute10 := l_camp_rec.program_attribute10;
   END IF;

   IF p_camp_rec.program_attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute11 := l_camp_rec.program_attribute11;
   END IF;

   IF p_camp_rec.program_attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute12 := l_camp_rec.program_attribute12;
   END IF;

   IF p_camp_rec.program_attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute13 := l_camp_rec.program_attribute13 ;
   END IF;

   IF p_camp_rec.program_attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute14 := l_camp_rec.program_attribute14 ;
   END IF;

   IF p_camp_rec.program_attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.program_attribute15 := l_camp_rec.program_attribute15;
   END IF;


END Complete_Camp_Rec;


END AMS_Campaign_PVT;

/
